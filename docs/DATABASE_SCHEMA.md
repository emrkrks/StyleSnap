# StyleSnap - Supabase Database Schema

## Database Overview

**Database**: PostgreSQL (Supabase managed)
**Extensions Required**:
- `uuid-ossp` (UUID generation)
- `pg_trgm` (Full-text search)

---

## Tables

### 1. users

User profiles and authentication data.

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Auth (managed by Supabase Auth)
  auth_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
  
  -- Profile
  email TEXT UNIQUE,
  phone TEXT UNIQUE,
  name TEXT NOT NULL,
  avatar_url TEXT,
  bio TEXT,
  
  -- Preferences
  gender TEXT CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
  age_range TEXT CHECK (age_range IN ('18-24', '25-34', '35-44', '45-54', '55+')),
  body_type TEXT CHECK (body_type IN ('hourglass', 'pear', 'apple', 'rectangle', 'triangle')),
  skin_tone TEXT,
  
  -- Location
  city TEXT,
  country_code TEXT,
  timezone TEXT,
  
  -- Style Preferences (JSON array)
  style_preferences JSONB DEFAULT '[]'::jsonb,
  -- Example: ["casual", "business", "elegant"]
  
  favorite_colors JSONB DEFAULT '[]'::jsonb,
  -- Example: ["#FF0000", "#00FF00", "#0000FF"]
  
  -- Settings
  language TEXT DEFAULT 'en' CHECK (language IN ('en', 'tr', 'es')),
  currency TEXT DEFAULT 'USD',
  measurement_unit TEXT DEFAULT 'metric' CHECK (measurement_unit IN ('metric', 'imperial')),
  
  -- Onboarding
  onboarding_completed BOOLEAN DEFAULT FALSE,
  onboarding_step INTEGER DEFAULT 0,
  
  -- Subscription
  subscription_status TEXT DEFAULT 'free' CHECK (subscription_status IN ('free', 'premium', 'vip')),
  subscription_expires_at TIMESTAMP WITH TIME ZONE,
  
  -- Notifications
  notifications_enabled BOOLEAN DEFAULT TRUE,
  daily_reminder_time TIME DEFAULT '08:00:00',
  
  -- Analytics
  referral_code TEXT UNIQUE,
  referred_by UUID REFERENCES users(id),
  total_referrals INTEGER DEFAULT 0,
  
  -- Soft delete
  deleted_at TIMESTAMP WITH TIME ZONE
);

-- Indexes
CREATE INDEX idx_users_auth_id ON users(auth_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_referral_code ON users(referral_code);
CREATE INDEX idx_users_created_at ON users(created_at);

-- Trigger for updated_at
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

---

### 2. clothes

Individual clothing items in user's wardrobe.

```sql
CREATE TABLE clothes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Ownership
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  
  -- Images
  image_url TEXT NOT NULL,
  thumbnail_url TEXT,
  background_removed_url TEXT,
  
  -- AI Analysis Results
  category TEXT NOT NULL CHECK (category IN (
    'tops', 'bottoms', 'dresses', 'outerwear', 
    'shoes', 'accessories', 'bags', 'jewelry'
  )),
  
  subcategory TEXT,
  -- Examples: t-shirt, jeans, sneakers, necklace
  
  colors JSONB NOT NULL DEFAULT '[]'::jsonb,
  -- Example: [{"color": "#FF0000", "name": "red", "percentage": 80}]
  
  patterns JSONB DEFAULT '[]'::jsonb,
  -- Example: ["solid", "striped", "floral"]
  
  materials JSONB DEFAULT '[]'::jsonb,
  -- Example: ["cotton", "polyester"]
  
  seasons JSONB DEFAULT '[]'::jsonb,
  -- Example: ["spring", "summer"]
  
  styles JSONB DEFAULT '[]'::jsonb,
  -- Example: ["casual", "sporty"]
  
  -- Manual Metadata
  brand TEXT,
  purchase_date DATE,
  purchase_price DECIMAL(10, 2),
  purchase_currency TEXT DEFAULT 'USD',
  notes TEXT,
  
  -- AI Confidence Scores
  ai_confidence DECIMAL(3, 2),
  -- 0.00 to 1.00
  
  ai_model_version TEXT DEFAULT 'gemini-1.5-flash',
  
  -- Manual override flags
  manually_edited BOOLEAN DEFAULT FALSE,
  
  -- Usage Stats
  favorite BOOLEAN DEFAULT FALSE,
  times_worn INTEGER DEFAULT 0,
  last_worn_at TIMESTAMP WITH TIME ZONE,
  
  -- State
  archived BOOLEAN DEFAULT FALSE,
  deleted_at TIMESTAMP WITH TIME ZONE
);

-- Indexes
CREATE INDEX idx_clothes_user_id ON clothes(user_id);
CREATE INDEX idx_clothes_category ON clothes(category);
CREATE INDEX idx_clothes_created_at ON clothes(created_at);
CREATE INDEX idx_clothes_favorite ON clothes(favorite) WHERE favorite = TRUE;
CREATE INDEX idx_clothes_colors_gin ON clothes USING GIN(colors);
CREATE INDEX idx_clothes_seasons_gin ON clothes USING GIN(seasons);

-- Full-text search
CREATE INDEX idx_clothes_search ON clothes USING GIN(
  to_tsvector('english', coalesce(brand, '') || ' ' || coalesce(notes, ''))
);

-- Trigger for updated_at
CREATE TRIGGER update_clothes_updated_at
  BEFORE UPDATE ON clothes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

---

### 3. outfits

Outfit combinations (user-created or AI-generated).

```sql
CREATE TABLE outfits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Ownership
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  
  -- Outfit Info
  name TEXT NOT NULL,
  description TEXT,
  
  -- Items (array of clothing IDs)
  clothing_ids UUID[] NOT NULL,
  -- Enforced to have at least 2 items
  
  -- Context
  occasion TEXT,
  -- Examples: casual, work, date, party, gym
  
  weather_conditions JSONB,
  -- Example: {"temp_min": 15, "temp_max": 25, "condition": "sunny"}
  
  season TEXT CHECK (season IN ('spring', 'summer', 'fall', 'winter')),
  
  -- Source
  source TEXT DEFAULT 'user' CHECK (source IN ('user', 'ai', 'celebrity')),
  ai_model_version TEXT,
  celebrity_reference TEXT,
  -- Example: "bella_hadid_coachella_2024"
  
  -- Images
  composite_image_url TEXT,
  shared_image_url TEXT,
  -- With watermark for sharing
  
  -- Stats
  favorite BOOLEAN DEFAULT FALSE,
  times_worn INTEGER DEFAULT 0,
  last_worn_at TIMESTAMP WITH TIME ZONE,
  times_shared INTEGER DEFAULT 0,
  
  -- AI Scores
  style_score DECIMAL(3, 2),
  -- 0.00 to 1.00 - how well items match
  
  weather_score DECIMAL(3, 2),
  -- 0.00 to 1.00 - appropriateness for weather
  
  -- State
  archived BOOLEAN DEFAULT FALSE,
  deleted_at TIMESTAMP WITH TIME ZONE
);

-- Indexes
CREATE INDEX idx_outfits_user_id ON outfits(user_id);
CREATE INDEX idx_outfits_created_at ON outfits(created_at);
CREATE INDEX idx_outfits_favorite ON outfits(favorite) WHERE favorite = TRUE;
CREATE INDEX idx_outfits_occasion ON outfits(occasion);
CREATE INDEX idx_outfits_season ON outfits(season);
CREATE INDEX idx_outfits_source ON outfits(source);
CREATE INDEX idx_outfits_clothing_ids_gin ON outfits USING GIN(clothing_ids);

-- Trigger
CREATE TRIGGER update_outfits_updated_at
  BEFORE UPDATE ON outfits
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

---

### 4. recommendations

AI-generated daily outfit recommendations.

```sql
CREATE TABLE recommendations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Ownership
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  
  -- Recommendation Date
  recommendation_date DATE NOT NULL,
  -- One set per day
  
  -- Outfits (array of outfit IDs)
  outfit_ids UUID[] NOT NULL,
  -- Typically 3 outfits per day
  
  -- Context
  weather_data JSONB NOT NULL,
  -- Full weather API response
  
  calendar_events JSONB DEFAULT '[]'::jsonb,
  -- User's calendar for the day (if integrated)
  
  mood TEXT,
  -- From facial analysis or manual input
  
  -- Interaction
  viewed BOOLEAN DEFAULT FALSE,
  viewed_at TIMESTAMP WITH TIME ZONE,
  
  outfit_selected UUID REFERENCES outfits(id),
  -- Which outfit user chose
  
  -- AI Metadata
  ai_model_version TEXT DEFAULT 'gemini-1.5-flash',
  generation_time_ms INTEGER
);

-- Indexes
CREATE INDEX idx_recommendations_user_id ON recommendations(user_id);
CREATE INDEX idx_recommendations_date ON recommendations(recommendation_date);
CREATE UNIQUE INDEX idx_recommendations_user_date ON recommendations(user_id, recommendation_date);

-- Constraint: One recommendation set per user per day
ALTER TABLE recommendations
  ADD CONSTRAINT unique_user_recommendation_date 
  UNIQUE (user_id, recommendation_date);
```

---

### 5. purchases

User purchases (subscriptions & one-time).

```sql
CREATE TABLE purchases (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Ownership
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  
  -- Purchase Info
  purchase_type TEXT NOT NULL CHECK (purchase_type IN ('subscription', 'one_time')),
  
  product_id TEXT NOT NULL,
  -- RevenueCat product identifier
  -- Examples: "premium_monthly", "celebrity_pack_bella", "outfit_pack_winter"
  
  price_usd DECIMAL(10, 2) NOT NULL,
  price_local DECIMAL(10, 2),
  currency TEXT DEFAULT 'USD',
  
  -- Provider
  provider TEXT NOT NULL CHECK (provider IN ('apple', 'google', 'stripe')),
  provider_transaction_id TEXT UNIQUE,
  
  -- Subscription Details (if applicable)
  subscription_period TEXT,
  -- monthly, yearly
  
  subscription_start_date TIMESTAMP WITH TIME ZONE,
  subscription_end_date TIMESTAMP WITH TIME ZONE,
  
  auto_renew BOOLEAN DEFAULT TRUE,
  
  -- Status
  status TEXT DEFAULT 'active' CHECK (status IN (
    'pending', 'active', 'cancelled', 'expired', 'refunded'
  )),
  
  cancelled_at TIMESTAMP WITH TIME ZONE,
  refunded_at TIMESTAMP WITH TIME ZONE,
  refund_amount DECIMAL(10, 2),
  
  -- Revenue Tracking
  commission_rate DECIMAL(5, 4) DEFAULT 0.70,
  -- 70% after stores' 30% cut
  
  net_revenue DECIMAL(10, 2) GENERATED ALWAYS AS (price_usd * commission_rate) STORED,
  
  -- Metadata
  receipt_data TEXT,
  revenucat_customer_info JSONB
);

-- Indexes
CREATE INDEX idx_purchases_user_id ON purchases(user_id);
CREATE INDEX idx_purchases_created_at ON purchases(created_at);
CREATE INDEX idx_purchases_status ON purchases(status);
CREATE INDEX idx_purchases_product_id ON purchases(product_id);
CREATE INDEX idx_purchases_provider_transaction_id ON purchases(provider_transaction_id);
```

---

### 6. affiliate_clicks

Tracking for affiliate link clicks.

```sql
CREATE TABLE affiliate_clicks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Ownership
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- Affiliate Info
  partner TEXT NOT NULL CHECK (partner IN ('trendyol', 'zara', 'hm', 'shein', 'asos', 'other')),
  
  product_url TEXT NOT NULL,
  affiliate_url TEXT NOT NULL,
  
  -- Context
  product_name TEXT,
  product_price DECIMAL(10, 2),
  product_currency TEXT,
  
  source_outfit_id UUID REFERENCES outfits(id),
  source_clothing_id UUID REFERENCES clothes(id),
  -- What prompted the click
  
  -- Conversion Tracking
  converted BOOLEAN DEFAULT FALSE,
  conversion_amount DECIMAL(10, 2),
  commission_earned DECIMAL(10, 2),
  
  -- Metadata
  user_agent TEXT,
  ip_address INET,
  country TEXT
);

-- Indexes
CREATE INDEX idx_affiliate_clicks_user_id ON affiliate_clicks(user_id);
CREATE INDEX idx_affiliate_clicks_created_at ON affiliate_clicks(created_at);
CREATE INDEX idx_affiliate_clicks_partner ON affiliate_clicks(partner);
CREATE INDEX idx_affiliate_clicks_converted ON affiliate_clicks(converted) WHERE converted = TRUE;
```

---

### 7. social_shares

Tracking social media shares (viral loop).

```sql
CREATE TABLE social_shares (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Ownership
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  
  -- Shared Content
  outfit_id UUID REFERENCES outfits(id) ON DELETE SET NULL,
  share_image_url TEXT NOT NULL,
  
  -- Platform
  platform TEXT NOT NULL CHECK (platform IN ('instagram', 'tiktok', 'twitter', 'facebook', 'other')),
  
  -- Deep Link Tracking
  deep_link_code TEXT UNIQUE NOT NULL,
  -- Short code for attributing installs
  
  clicks INTEGER DEFAULT 0,
  installs INTEGER DEFAULT 0,
  
  -- Attribution
  referred_users UUID[],
  -- Users who installed from this share
  
  -- Rewards
  reward_earned DECIMAL(10, 2) DEFAULT 0.00
);

-- Indexes
CREATE INDEX idx_social_shares_user_id ON social_shares(user_id);
CREATE INDEX idx_social_shares_deep_link_code ON social_shares(deep_link_code);
CREATE INDEX idx_social_shares_platform ON social_shares(platform);
```

---

### 8. analytics_events

General app analytics (supplement to Mixpanel).

```sql
CREATE TABLE analytics_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- User (optional for anonymous events)
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- Event
  event_name TEXT NOT NULL,
  event_properties JSONB DEFAULT '{}'::jsonb,
  
  -- Session
  session_id TEXT,
  
  -- Device
  platform TEXT CHECK (platform IN ('ios', 'android', 'web')),
  app_version TEXT,
  os_version TEXT,
  device_model TEXT,
  
  -- Location
  country TEXT,
  city TEXT,
  
  -- Partitioning by month for performance
  event_month TEXT GENERATED ALWAYS AS (to_char(created_at, 'YYYY-MM')) STORED
);

-- Indexes
CREATE INDEX idx_analytics_events_user_id ON analytics_events(user_id);
CREATE INDEX idx_analytics_events_event_name ON analytics_events(event_name);
CREATE INDEX idx_analytics_events_created_at ON analytics_events(created_at);
CREATE INDEX idx_analytics_events_month ON analytics_events(event_month);
```

---

## Row Level Security (RLS) Policies

Enable RLS on all tables:

```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE clothes ENABLE ROW LEVEL SECURITY;
ALTER TABLE outfits ENABLE ROW LEVEL SECURITY;
ALTER TABLE recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE affiliate_clicks ENABLE ROW LEVEL SECURITY;
ALTER TABLE social_shares ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;
```

### Users Table Policies

```sql
-- Users can read their own profile
CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  USING (auth.uid() = auth_id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth.uid() = auth_id);

-- Users can insert their own profile (signup)
CREATE POLICY "Users can insert own profile"
  ON users FOR INSERT
  WITH CHECK (auth.uid() = auth_id);
```

### Clothes Table Policies

```sql
-- Users can view their own clothes
CREATE POLICY "Users can view own clothes"
  ON clothes FOR SELECT
  USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- Users can insert their own clothes
CREATE POLICY "Users can insert own clothes"
  ON clothes FOR INSERT
  WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- Users can update their own clothes
CREATE POLICY "Users can update own clothes"
  ON clothes FOR UPDATE
  USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- Users can delete their own clothes
CREATE POLICY "Users can delete own clothes"
  ON clothes FOR DELETE
  USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
```

### Outfits Table Policies

```sql
-- Users can view their own outfits
CREATE POLICY "Users can view own outfits"
  ON outfits FOR SELECT
  USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- Users can insert own outfits
CREATE POLICY "Users can insert own outfits"
  ON outfits FOR INSERT
  WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- Users can update own outfits
CREATE POLICY "Users can update own outfits"
  ON outfits FOR UPDATE
  USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- Users can delete own outfits
CREATE POLICY "Users can delete own outfits"
  ON outfits FOR DELETE
  USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
```

### Recommendations Table Policies

```sql
-- Users can view their own recommendations
CREATE POLICY "Users can view own recommendations"
  ON recommendations FOR SELECT
  USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- Service role can insert recommendations (backend job)
CREATE POLICY "Service can insert recommendations"
  ON recommendations FOR INSERT
  WITH CHECK (true);

-- Users can update viewed status
CREATE POLICY "Users can update own recommendations"
  ON recommendations FOR UPDATE
  USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
```

### Purchases Table Policies

```sql
-- Users can view their own purchases
CREATE POLICY "Users can view own purchases"
  ON purchases FOR SELECT
  USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- Service role can insert purchases (webhook from RevenueCat)
CREATE POLICY "Service can insert purchases"
  ON purchases FOR INSERT
  WITH CHECK (true);

-- Service role can update purchases (subscription changes)
CREATE POLICY "Service can update purchases"
  ON purchases FOR UPDATE
  WITH CHECK (true);
```

### Affiliate Clicks Policies

```sql
-- Users can view their own clicks
CREATE POLICY "Users can view own clicks"
  ON affiliate_clicks FOR SELECT
  USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- Users can insert clicks
CREATE POLICY "Users can insert clicks"
  ON affiliate_clicks FOR INSERT
  WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));
```

### Social Shares Policies

```sql
-- Users can view their own shares
CREATE POLICY "Users can view own shares"
  ON social_shares FOR SELECT
  USING (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- Users can insert shares
CREATE POLICY "Users can insert shares"
  ON social_shares FOR INSERT
  WITH CHECK (auth.uid() = (SELECT auth_id FROM users WHERE id = user_id));

-- Anyone can update click/install counts (via edge function)
CREATE POLICY "Public can update share stats"
  ON social_shares FOR UPDATE
  USING (true);
```

---

## Functions

### Update updated_at Column

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Generate Referral Code

```sql
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
```

### Trigger: Auto-generate Referral Code

```sql
CREATE OR REPLACE FUNCTION auto_generate_referral_code()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.referral_code IS NULL THEN
    NEW.referral_code := generate_referral_code();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_generate_referral_code
  BEFORE INSERT ON users
  FOR EACH ROW
  EXECUTE FUNCTION auto_generate_referral_code();
```

---

## Storage Buckets

Configure Supabase Storage for images:

### Bucket: `user-avatars`
- **Public**: Yes
- **File size limit**: 5MB
- **Allowed MIME types**: `image/jpeg`, `image/png`, `image/webp`

### Bucket: `clothing-images`
- **Public**: Yes
- **File size limit**: 10MB
- **Allowed MIME types**: `image/jpeg`, `image/png`, `image/webp`

### Bucket: `outfit-images`
- **Public**: Yes
- **File size limit**: 10MB
- **Allowed MIME types**: `image/jpeg`, `image/png`, `image/webp`

### Bucket: `shared-images`
- **Public**: Yes
- **File size limit**: 10MB
- **Allowed MIME types**: `image/jpeg`, `image/png`
- **Note**: For watermarked social sharing images

---

## Database Migrations

Execute in Supabase SQL Editor in this order:

1. **Create extensions**: `uuid-ossp`, `pg_trgm`
2. **Create function**: `update_updated_at_column()`
3. **Create function**: `generate_referral_code()`, `auto_generate_referral_code()`
4. **Create tables**: Execute all CREATE TABLE statements
5. **Enable RLS**: Execute all ALTER TABLE ENABLE RLS
6. **Create policies**: Execute all CREATE POLICY statements
7. **Create storage buckets**: Use Supabase Dashboard

---

**Total Tables**: 8
**Total Policies**: 20+
**Total Functions**: 3
**Storage Buckets**: 4
