-- ========================================
-- StyleSnap - Complete Database Migration
-- ========================================
-- Run this in Supabase SQL Editor: https://app.supabase.com/project/rhixhiczhrvxrhlyncqr
--
-- This script creates:
-- - 8 tables (users, clothes, outfits, recommendations, purchases, affiliate_clicks, social_shares, analytics_events)
-- - All indexes for performance
-- - All triggers for auto-updates
-- - Row Level Security (RLS) policies
--
-- Execute time: ~30 seconds
-- ========================================

-- ====================================
-- STEP 1: Enable Extensions
-- ====================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ====================================
-- STEP 2: Create Utility Functions
-- ====================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Generate random referral code
CREATE OR REPLACE FUNCTION generate_referral_code()
RETURNS TEXT AS $$
DECLARE
  chars TEXT := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  result TEXT := '';
  i INTEGER := 0;
BEGIN
  FOR i IN 1..8 LOOP
    result := result || substr(chars, floor(random() * length(chars) + 1)::int, 1);
  END LOOP;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Auto-generate referral code on user insert
CREATE OR REPLACE FUNCTION auto_generate_referral_code()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.referral_code IS NULL THEN
    NEW.referral_code := generate_referral_code();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Auto-populate event_month for analytics
CREATE OR REPLACE FUNCTION set_event_month()
RETURNS TRIGGER AS $$
BEGIN
  NEW.event_month := to_char(NEW.created_at, 'YYYY-MM');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ====================================
-- STEP 3: Create Tables
-- ====================================

-- TABLE 1: users
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  auth_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  email TEXT UNIQUE,
  phone TEXT UNIQUE,
  name TEXT NOT NULL,
  avatar_url TEXT,
  bio TEXT,
  gender TEXT CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
  age_range TEXT CHECK (age_range IN ('18-24', '25-34', '35-44', '45-54', '55+')),
  body_type TEXT CHECK (body_type IN ('hourglass', 'pear', 'apple', 'rectangle', 'triangle')),
  skin_tone TEXT,
  city TEXT,
  country_code TEXT,
  timezone TEXT,
  style_preferences JSONB DEFAULT '[]'::jsonb,
  favorite_colors JSONB DEFAULT '[]'::jsonb,
  language TEXT DEFAULT 'en' CHECK (language IN ('en', 'tr', 'es')),
  currency TEXT DEFAULT 'USD',
  measurement_unit TEXT DEFAULT 'metric' CHECK (measurement_unit IN ('metric', 'imperial')),
  onboarding_completed BOOLEAN DEFAULT FALSE,
  onboarding_step INTEGER DEFAULT 0,
  subscription_status TEXT DEFAULT 'free' CHECK (subscription_status IN ('free', 'premium', 'vip')),
  subscription_expires_at TIMESTAMP WITH TIME ZONE,
  notifications_enabled BOOLEAN DEFAULT TRUE,
  daily_reminder_time TIME DEFAULT '08:00:00',
  referral_code TEXT UNIQUE,
  referred_by UUID REFERENCES users(id),
  total_referrals INTEGER DEFAULT 0,
  deleted_at TIMESTAMP WITH TIME ZONE
);

-- TABLE 2: clothes
CREATE TABLE IF NOT EXISTS clothes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  image_url TEXT NOT NULL,
  thumbnail_url TEXT,
  background_removed_url TEXT,
  category TEXT NOT NULL CHECK (category IN ('tops', 'bottoms', 'dresses', 'outerwear', 'shoes', 'accessories', 'bags', 'jewelry')),
  subcategory TEXT,
  colors JSONB NOT NULL DEFAULT '[]'::jsonb,
  patterns JSONB DEFAULT '[]'::jsonb,
  materials JSONB DEFAULT '[]'::jsonb,
  seasons JSONB DEFAULT '[]'::jsonb,
  styles JSONB DEFAULT '[]'::jsonb,
  brand TEXT,
  purchase_date DATE,
  purchase_price DECIMAL(10, 2),
  purchase_currency TEXT DEFAULT 'USD',
  notes TEXT,
  ai_confidence DECIMAL(3, 2),
  ai_model_version TEXT DEFAULT 'gemini-1.5-flash',
  manually_edited BOOLEAN DEFAULT FALSE,
  favorite BOOLEAN DEFAULT FALSE,
  times_worn INTEGER DEFAULT 0,
  last_worn_at TIMESTAMP WITH TIME ZONE,
  archived BOOLEAN DEFAULT FALSE,
  deleted_at TIMESTAMP WITH TIME ZONE
);

-- TABLE 3: outfits
CREATE TABLE IF NOT EXISTS outfits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  clothing_ids UUID[] NOT NULL,
  occasion TEXT,
  weather_conditions JSONB,
  season TEXT CHECK (season IN ('spring', 'summer', 'fall', 'winter')),
  source TEXT DEFAULT 'user' CHECK (source IN ('user', 'ai', 'celebrity')),
  ai_model_version TEXT,
  celebrity_reference TEXT,
  composite_image_url TEXT,
  shared_image_url TEXT,
  favorite BOOLEAN DEFAULT FALSE,
  times_worn INTEGER DEFAULT 0,
  last_worn_at TIMESTAMP WITH TIME ZONE,
  times_shared INTEGER DEFAULT 0,
  style_score DECIMAL(3, 2),
  weather_score DECIMAL(3, 2),
  archived BOOLEAN DEFAULT FALSE,
  deleted_at TIMESTAMP WITH TIME ZONE
);

-- TABLE 4: recommendations
CREATE TABLE IF NOT EXISTS recommendations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  recommendation_date DATE NOT NULL,
  outfit_ids UUID[] NOT NULL,
  weather_data JSONB NOT NULL,
  calendar_events JSONB DEFAULT '[]'::jsonb,
  mood TEXT,
  viewed BOOLEAN DEFAULT FALSE,
  viewed_at TIMESTAMP WITH TIME ZONE,
  outfit_selected UUID REFERENCES outfits(id),
  ai_model_version TEXT DEFAULT 'gemini-1.5-flash',
  generation_time_ms INTEGER,
  CONSTRAINT unique_user_recommendation_date UNIQUE (user_id, recommendation_date)
);

-- TABLE 5: purchases
CREATE TABLE IF NOT EXISTS purchases (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  purchase_type TEXT NOT NULL CHECK (purchase_type IN ('subscription', 'one_time')),
  product_id TEXT NOT NULL,
  price_usd DECIMAL(10, 2) NOT NULL,
  price_local DECIMAL(10, 2),
  currency TEXT DEFAULT 'USD',
  provider TEXT NOT NULL CHECK (provider IN ('apple', 'google', 'stripe')),
  provider_transaction_id TEXT UNIQUE,
  subscription_period TEXT,
  subscription_start_date TIMESTAMP WITH TIME ZONE,
  subscription_end_date TIMESTAMP WITH TIME ZONE,
  auto_renew BOOLEAN DEFAULT TRUE,
  status TEXT DEFAULT 'active' CHECK (status IN ('pending', 'active', 'cancelled', 'expired', 'refunded')),
  cancelled_at TIMESTAMP WITH TIME ZONE,
  refunded_at TIMESTAMP WITH TIME ZONE,
  refund_amount DECIMAL(10, 2),
  commission_rate DECIMAL(5, 4) DEFAULT 0.70,
  net_revenue DECIMAL(10, 2) GENERATED ALWAYS AS (price_usd * commission_rate) STORED,
  receipt_data TEXT,
  revenucat_customer_info JSONB
);

-- TABLE 6: affiliate_clicks
CREATE TABLE IF NOT EXISTS affiliate_clicks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  partner TEXT NOT NULL CHECK (partner IN ('trendyol', 'zara', 'hm', 'shein', 'asos', 'other')),
  product_url TEXT NOT NULL,
  affiliate_url TEXT NOT NULL,
  product_name TEXT,
  product_price DECIMAL(10, 2),
  product_currency TEXT,
  source_outfit_id UUID REFERENCES outfits(id),
  source_clothing_id UUID REFERENCES clothes(id),
  converted BOOLEAN DEFAULT FALSE,
  conversion_amount DECIMAL(10, 2),
  commission_earned DECIMAL(10, 2),
  user_agent TEXT,
  ip_address INET,
  country TEXT
);

-- TABLE 7: social_shares
CREATE TABLE IF NOT EXISTS social_shares (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  outfit_id UUID REFERENCES outfits(id) ON DELETE SET NULL,
  share_image_url TEXT NOT NULL,
  platform TEXT NOT NULL CHECK (platform IN ('instagram', 'tiktok', 'twitter', 'facebook', 'other')),
  deep_link_code TEXT UNIQUE NOT NULL,
  clicks INTEGER DEFAULT 0,
  installs INTEGER DEFAULT 0,
  referred_users UUID[],
  reward_earned DECIMAL(10, 2) DEFAULT 0.00
);

-- TABLE 8: analytics_events
CREATE TABLE IF NOT EXISTS analytics_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  event_name TEXT NOT NULL,
  event_properties JSONB DEFAULT '{}'::jsonb,
  session_id TEXT,
  platform TEXT CHECK (platform IN ('ios', 'android', 'web')),
  app_version TEXT,
  os_version TEXT,
  device_model TEXT,
  country TEXT,
  city TEXT,
  event_month TEXT
);

-- ====================================
-- STEP 4: Create Indexes
-- ====================================

-- Users indexes
CREATE INDEX IF NOT EXISTS idx_users_auth_id ON users(auth_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_referral_code ON users(referral_code);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at);

-- Clothes indexes
CREATE INDEX IF NOT EXISTS idx_clothes_user_id ON clothes(user_id);
CREATE INDEX IF NOT EXISTS idx_clothes_category ON clothes(category);
CREATE INDEX IF NOT EXISTS idx_clothes_created_at ON clothes(created_at);
CREATE INDEX IF NOT EXISTS idx_clothes_favorite ON clothes(favorite) WHERE favorite = TRUE;
CREATE INDEX IF NOT EXISTS idx_clothes_colors_gin ON clothes USING GIN(colors);
CREATE INDEX IF NOT EXISTS idx_clothes_seasons_gin ON clothes USING GIN(seasons);
CREATE INDEX IF NOT EXISTS idx_clothes_search ON clothes USING GIN(to_tsvector('english', coalesce(brand, '') || ' ' || coalesce(notes, '')));

-- Outfits indexes
CREATE INDEX IF NOT EXISTS idx_outfits_user_id ON outfits(user_id);
CREATE INDEX IF NOT EXISTS idx_outfits_created_at ON outfits(created_at);
CREATE INDEX IF NOT EXISTS idx_outfits_favorite ON outfits(favorite) WHERE favorite = TRUE;
CREATE INDEX IF NOT EXISTS idx_outfits_occasion ON outfits(occasion);
CREATE INDEX IF NOT EXISTS idx_outfits_season ON outfits(season);
CREATE INDEX IF NOT EXISTS idx_outfits_source ON outfits(source);
CREATE INDEX IF NOT EXISTS idx_outfits_clothing_ids_gin ON outfits USING GIN(clothing_ids);

-- Recommendations indexes
CREATE INDEX IF NOT EXISTS idx_recommendations_user_id ON recommendations(user_id);
CREATE INDEX IF NOT EXISTS idx_recommendations_date ON recommendations(recommendation_date);
CREATE INDEX IF NOT EXISTS idx_recommendations_user_date ON recommendations(user_id, recommendation_date);

-- Purchases indexes
CREATE INDEX IF NOT EXISTS idx_purchases_user_id ON purchases(user_id);
CREATE INDEX IF NOT EXISTS idx_purchases_created_at ON purchases(created_at);
CREATE INDEX IF NOT EXISTS idx_purchases_status ON purchases(status);
CREATE INDEX IF NOT EXISTS idx_purchases_product_id ON purchases(product_id);
CREATE INDEX IF NOT EXISTS idx_purchases_provider_transaction_id ON purchases(provider_transaction_id);

-- Affiliate clicks indexes
CREATE INDEX IF NOT EXISTS idx_affiliate_clicks_user_id ON affiliate_clicks(user_id);
CREATE INDEX IF NOT EXISTS idx_affiliate_clicks_created_at ON affiliate_clicks(created_at);
CREATE INDEX IF NOT EXISTS idx_affiliate_clicks_partner ON affiliate_clicks(partner);
CREATE INDEX IF NOT EXISTS idx_affiliate_clicks_converted ON affiliate_clicks(converted) WHERE converted = TRUE;

-- Social shares indexes
CREATE INDEX IF NOT EXISTS idx_social_shares_user_id ON social_shares(user_id);
CREATE INDEX IF NOT EXISTS idx_social_shares_deep_link_code ON social_shares(deep_link_code);
CREATE INDEX IF NOT EXISTS idx_social_shares_platform ON social_shares(platform);

-- Analytics events indexes
CREATE INDEX IF NOT EXISTS idx_analytics_events_user_id ON analytics_events(user_id);
CREATE INDEX IF NOT EXISTS idx_analytics_events_event_name ON analytics_events(event_name);
CREATE INDEX IF NOT EXISTS idx_analytics_events_created_at ON analytics_events(created_at);
CREATE INDEX IF NOT EXISTS idx_analytics_events_month ON analytics_events(event_month);

-- ====================================
-- STEP 5: Create Triggers
-- ====================================

-- Users triggers
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS trigger_generate_referral_code ON users;
CREATE TRIGGER trigger_generate_referral_code BEFORE INSERT ON users FOR EACH ROW EXECUTE FUNCTION auto_generate_referral_code();

-- Clothes triggers
DROP TRIGGER IF EXISTS update_clothes_updated_at ON clothes;
CREATE TRIGGER update_clothes_updated_at BEFORE UPDATE ON clothes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Outfits triggers
DROP TRIGGER IF EXISTS update_outfits_updated_at ON outfits;
CREATE TRIGGER update_outfits_updated_at BEFORE UPDATE ON outfits FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Analytics events trigger
DROP TRIGGER IF EXISTS set_analytics_event_month ON analytics_events;
CREATE TRIGGER set_analytics_event_month BEFORE INSERT ON analytics_events FOR EACH ROW EXECUTE FUNCTION set_event_month();

-- ====================================
-- STEP 6: Enable Row Level Security
-- ====================================

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE clothes ENABLE ROW LEVEL SECURITY;
ALTER TABLE outfits ENABLE ROW LEVEL SECURITY;
ALTER TABLE recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE affiliate_clicks ENABLE ROW LEVEL SECURITY;
ALTER TABLE social_shares ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;

-- ====================================
-- STEP 7: Create RLS Policies
-- ====================================

-- Drop all existing policies
DROP POLICY IF EXISTS "Users can view own profile" ON users;
DROP POLICY IF EXISTS "Users can update own profile" ON users;
DROP POLICY IF EXISTS "Users can insert own profile" ON users;
DROP POLICY IF EXISTS "Users can view own clothes" ON clothes;
DROP POLICY IF EXISTS "Users can insert own clothes" ON clothes;
DROP POLICY IF EXISTS "Users can update own clothes" ON clothes;
DROP POLICY IF EXISTS "Users can delete own clothes" ON clothes;
DROP POLICY IF EXISTS "Users can view own outfits" ON outfits;
DROP POLICY IF EXISTS "Users can insert own outfits" ON outfits;
DROP POLICY IF EXISTS "Users can update own outfits" ON outfits;
DROP POLICY IF EXISTS "Users can delete own outfits" ON outfits;
DROP POLICY IF EXISTS "Users can view own recommendations" ON recommendations;
DROP POLICY IF EXISTS "Service can insert recommendations" ON recommendations;
DROP POLICY IF EXISTS "Users can update own recommendations" ON recommendations;
DROP POLICY IF EXISTS "Users can view own purchases" ON purchases;
DROP POLICY IF EXISTS "Service can insert purchases" ON purchases;
DROP POLICY IF EXISTS "Service can update purchases" ON purchases;
DROP POLICY IF EXISTS "Users can view own clicks" ON affiliate_clicks;
DROP POLICY IF EXISTS "Users can insert clicks" ON affiliate_clicks;
DROP POLICY IF EXISTS "Users can view own shares" ON social_shares;
DROP POLICY IF EXISTS "Users can insert shares" ON social_shares;
DROP POLICY IF EXISTS "Public can update share stats" ON social_shares;

-- Users policies
CREATE POLICY "Users can view own profile" ON users FOR SELECT USING (auth.uid() = auth_id);
CREATE POLICY "Users can update own profile" ON users FOR UPDATE USING (auth.uid() = auth_id);
CREATE POLICY "Users can insert own profile" ON users FOR INSERT WITH CHECK (auth.uid() = auth_id);

-- Clothes policies  
CREATE POLICY "Users can view own clothes" ON clothes FOR SELECT USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
CREATE POLICY "Users can insert own clothes" ON clothes FOR INSERT WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
CREATE POLICY "Users can update own clothes" ON clothes FOR UPDATE USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
CREATE POLICY "Users can delete own clothes" ON clothes FOR DELETE USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- Outfits policies
CREATE POLICY "Users can view own outfits" ON outfits FOR SELECT USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
CREATE POLICY "Users can insert own outfits" ON outfits FOR INSERT WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
CREATE POLICY "Users can update own outfits" ON outfits FOR UPDATE USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
CREATE POLICY "Users can delete own outfits" ON outfits FOR DELETE USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- Recommendations policies
CREATE POLICY "Users can view own recommendations" ON recommendations FOR SELECT USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
CREATE POLICY "Service can insert recommendations" ON recommendations FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update own recommendations" ON recommendations FOR UPDATE USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- Purchases policies
CREATE POLICY "Users can view own purchases" ON purchases FOR SELECT USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
CREATE POLICY "Service can insert purchases" ON purchases FOR INSERT WITH CHECK (true);
CREATE POLICY "Service can update purchases" ON purchases FOR UPDATE WITH CHECK (true);

-- Affiliate clicks policies
CREATE POLICY "Users can view own clicks" ON affiliate_clicks FOR SELECT USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
CREATE POLICY "Users can insert clicks" ON affiliate_clicks FOR INSERT WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- Social shares policies
CREATE POLICY "Users can view own shares" ON social_shares FOR SELECT USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
CREATE POLICY "Users can insert shares" ON social_shares FOR INSERT WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
CREATE POLICY "Public can update share stats" ON social_shares FOR UPDATE USING (true);

-- ====================================
-- VERIFICATION
-- ====================================
SELECT 
  'Migration completed successfully!' as status,
  (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public') as total_tables,
  (SELECT COUNT(*) FROM pg_policies WHERE schemaname = 'public') as total_policies;
