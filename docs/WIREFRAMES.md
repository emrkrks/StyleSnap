# StyleSnap - Wireframe Specifications (32 Screens)

## Navigation Flow

```mermaid
graph TD
    A[Splash Screen] --> B[Onboarding 1]
    B --> C[Onboarding 2-5]
    C --> D[Login/Signup]
    D --> E[Phone OTP / Apple / Google]
    E --> F[Home Dashboard]
    F --> G[Wardrobe]
    F --> H[Recommendations]
    F --> I[Shopping]
    F --> J[Profile]
    G --> K[Add Item]
    H --> L[Outfit Details]
    L --> M[Share]
    I --> N[Affiliate Links]
    J --> O[Settings]
    O --> P[Paywall]
</mermaid>

---

## 1. Splash Screen

**Purpose**: Brand introduction, app initialization

**Layout**:
- Full-screen gradient background (Purple #8B5CF6 → Pink #EC4899)
- Centered logo (animated fade-in)
- App name "StyleSnap" below logo
- Tagline: "AI-Powered Style, Just for You"
- Progress indicator at bottom
- Version number (small, bottom corner)

**Interactions**:
- Auto-advances after 2 seconds
- Checks authentication status
- If logged in → Home Dashboard
- If not → Onboarding

**Assets Needed**:
- Logo (SVG, 200x200)
- Gradient background

---

## 2. O nboarding Screen 1 - Welcome

**Purpose**: Introduce app value proposition

**Layout**:
- Top 60%: Large hero illustration (AI analyzing clothes)
- Bottom 40%:
  - Headline: "Your AI Stylist in Your Pocket"
  - Subtext: "Get personalized outfit recommendations based on your wardrobe, weather, and style"
  - Progress dots (1 of 5 active)
  - "Next" button (primary CTA)
  - "Skip" link (top-right)

**Interactions**:
- Swipe left to next screen
- Tap "Next" → Screen 2
- Tap "Skip" → Login screen

**Assets Needed**:
- Hero illustration (generated AI image)

---

## 3. Onboarding Screen 2 - Style Quiz Intro

**Purpose**: Explain personalization process

**Layout**:
- Top 60%: Illustration (wardrobe with camera)
- Headline: "Scan Your Wardrobe"
- Subtext: "Take photos of your clothes and our AI will organize them automatically"
- Features list:
  - ✓ Auto-detect categories
  - ✓ Recognize colors & patterns
  - ✓ Organize by season
- Progress dots (2 of 5)
- "Next" button

**Interactions**:
- Swipe/tap next → Screen 3

---

## 4. Onboarding Screen 3 - AI Features

**Purpose**: Highlight AI outfit recommendations

**Layout**:
- Top 60%: Mockup of 3 outfit cards
- Headline: "3 Daily Outfit Picks"
- Subtext: "AI-curated combinations based on weather, your calendar, and mood"
- Features:
  - 🌤️ Weather-aware
  - 📅 Event-ready
  - ✨ Personalized
- Progress dots (3 of 5)
- "Next" button

---

## 5. Onboarding Screen 4 - Shopping

**Purpose**: Intro to affiliate shopping feature

**Layout**:
- Top 60%: Shopping interface mockup
- Headline: "Complete Your Look"
- Subtext: "Missing a piece? Get smart recommendations from top brands"
- Partner logos: Trendyol, Zara, H&M, Shein, ASOS
- Progress dots (4 of 5)
- "Next" button

---

## 6. Onboarding Screen 5 - Share & Go Viral

**Purpose**: Social sharing value proposition

**Layout**:
- Top 60%: Instagram/TikTok share preview
- Headline: "Share Your Style"
- Subtext: "One-tap sharing to Instagram & TikTok with your personal branding"
- CTA: "Get Started"
- Progress dots (5 of 5)
- "Already have account?" link

**Interactions**:
- "Get Started" → Login Screen

---

## 7. Login Screen

**Purpose**: Authentication entry point

**Layout**:
- Top 40%: Logo + gradient background
- Middle 60%:
  - Welcome back text
  - Phone number input field
    - Country code selector (flag icon)
    - Phone number field with formatting
  - OR divider line
  - "Continue with Apple" button (Apple brand guidelines)
  - "Continue with Google" button (Google brand guidelines)
  - Terms & Privacy footer text

**Interactions**:
- Phone → OTP Screen
- Apple/Google → OAuth flow → Home

**Form Validation**:
- Phone number format validation
- Country code auto-detection

---

## 8. OTP Verification Screen

**Purpose**: Phone number verification

**Layout**:
- Header: "Enter Code"
- Subtext: "We sent a code to +90 XXX XXX XX XX"
- 6-digit OTP input boxes (auto-focus)
- Countdown timer: "Resend in 0:45"
- "Resend Code" button (disabled until timer ends)
- "Change Number" link
- Auto-verify indicator

**Interactions**:
- Auto-submit when 6 digits entered
- Resend after 60 seconds
- Error state for invalid code

---

## 9. Profile Setup (First Time)

**Purpose**: Collect basic user preferences

**Layout**:
- Progress: Step 1 of 3
- Headline: "Tell us about yourself"
- Form fields:
  - Name input
  - Gender selection (cards): Male / Female / Other
  - Age range slider
  - Location (city auto-complete)
- "Next" button

---

## 10. Style Preference Quiz

**Purpose**: AI personalization data

**Layout**:
- Progress: Step 2 of 3
- Headline: "What's your style personality?"
- Multi-select style cards (6 options):
  - Casual
  - Business
  - Sporty
  - Elegant
  - Streetwear
  - Bohemian
- Visual examples for each
- "Select 1-3 styles"
- "Next" button (requires min 1 selection)

---

## 11. Body Type & Color Preferences

**Purpose**: Better fit recommendations

**Layout**:
- Progress: Step 3 of 3
- Top half: Body type selection (illustrated)
  - Hourglass, Pear, Apple, Rectangle, Triangle
- Bottom half: Favorite colors
  - Color palette selector (tap to select, max 5)
- "Finish Setup" button

**Interactions**:
- Selection optional
- Button → Permission requests

---

## 12. Permissions Request

**Purpose**: Get camera & notification permissions

**Layout**:
- Sequential permission prompts:
  1. Camera access (with explanation)
  2. Photo library access
  3. Notifications (with value prop)
- Each has:
  - Icon illustration
  - Title
  - Explanation text
  - "Allow" / "Not Now" buttons
- Can skip any

**Interactions**:
- After permissions → Home Dashboard

---

## 13. Home Dashboard

**Purpose**: Main app hub

**Layout**:
- **Header**:
  - "Good morning, [Name]" greeting
  - Weather widget (location, temp, icon)
  - Notification bell icon
  - Settings gear icon

- **Today's Outfits Section**:
  - "Your Picks for Today" headline
  - 3 horizontal outfit cards:
    - Card 1: "Casual Monday"
    - Card 2: "Meeting Ready"
    - Card 3: "Evening Out"
  - Each card shows:
    - Outfit image (composite)
    - Weather match indicator
    - "Try This" button

- **Quick Actions** (Icon buttons):
  - Add Item (+)
  - Scan Wardrobe
  - Browse Shopping

- **Stats Widget**:
  - Wardrobe items count
  - Outfits created
  - Money saved

- **Bottom Navigation**:
  - Home (active)
  - Wardrobe
  - Add (+)
  - Shopping
  - Profile

**Interactions**:
- Tap outfit card → Outfit Details (Screen 18)
- Tap notification → Notifications list
- Weather widget → Weekly forecast modal

---

## 14. Wardrobe Main Screen

**Purpose**: View and manage clothing collection

**Layout**:
- **Header**:
  - "My Wardrobe" title
  - Search icon
  - Filter icon (badge with active count)
  - Grid/List view toggle

- **Filter Chips** (horizontal scroll):
  - All (active)
  - Tops
  - Bottoms
  - Dresses
  - Shoes
  - Accessories
  - Outerwear

- **Wardrobe Grid** (2 columns):
  - Item cards with:
    - Item photo
    - Category badge
    - Favorite heart icon
  - Empty state: "Start adding items"

- **FAB**: Camera icon (primary action)

**Interactions**:
- Tap item → Item Detail (Screen 16)
- Tap FAB → Add Item options (Screen 15)
- Tap filter → Filter modal
- Tap search → Search screen

---

## 15. Add Item Options

**Purpose**: Choose method to add clothing

**Layout**:
- Bottom sheet modal:
  - "Add New Item" header
  - Options (large touch targets):
    1. 📸 Take Photo
       - "Scan with camera"
    2. 🖼️ Choose from Gallery
       - "Select multiple photos"
    3. ✍️ Add Manually
       - "Enter details yourself"
  - Cancel button

**Interactions**:
- Camera → Camera screen (Screen 16)
- Gallery → Multi-select picker
- Manual → Form entry

---

## 16. Camera Capture Screen

**Purpose**: Take photos of clothing items

**Layout**:
- Full-screen camera view
- **Overlays**:
  - Top: Flash toggle, flip camera
  - Center: Item framing guide (dotted rectangle)
  - Bottom:
    - Gallery thumbnail (recent)
    - Capture button (large circle)
    - Tips button ("Best photo tips")
  
- **Tips Modal** (toggle):
  - Good lighting
  - Flat surface or hanger
  - Full item visible
  - Simple background

**Interactions**:
- Capture → Processing screen → AI Analysis
- Gallery → System picker

---

## 17. AI Processing Screen

**Purpose**: Show AI analysis in progress

**Layout**:
- Center:
  - Captured image preview
  - Animated scanning overlay
  - Progress text:
    - "Analyzing image..." → "Detecting category..." → "Identifying colors..." → "Done!"
  - Progress bar (0-100%)
  
**Interactions**:
- Auto-advances when complete → Item detail edit screen

**Technical**:
- Calls Gemini API
- Parses JSON response
- Pre-fills form fields

---

## 18. Item Detail Edit Screen

**Purpose**: Review/edit AI-detected info

**Layout**:
- **Image Section** (top 40%):
  - Item photo (large)
  - Re-take button
  - Edit photo button

- **AI Results** (scrollable form):
  - Category (dropdown, AI-selected)
  - Color (multi-select chips, AI-selected)
  - Pattern (dropdown)
  - Season (chips: Spring/Summer/Fall/Winter)
  - Style tags (chips: casual, formal, etc.)
  - Brand (text input, optional)
  - Purchase date (date picker, optional)
  - Price (currency input, optional)
  - Notes (text area, optional)

- **Actions**:
  - "Save to Wardrobe" button (primary)
  - Delete button (subtle)

**Interactions**:
- Edit any field
- Save → Wardrobe screen with success toast

**Validation**:
- Category required
- At least one color

---

## 19. Item Detail View Screen

**Purpose**: View existing wardrobe item

**Layout**:
- Full-screen item image (can zoom/pan)
- Bottom sheet overlay:
  - Item name/category
  - All metadata (read-only view)
  - **Actions**:
    - Edit button
    - Delete button
    - Create Outfit button
    - Share button
  
- **Stats**:
  - Times worn
  - Last worn date
  - Outfits using this item (count)

**Interactions**:
- Tap Edit → Edit screen
- Create Outfit → Outfit builder
- Tap "Outfits" → List of outfits with this item

---

## 20. Recommendations Screen

**Purpose**: Daily outfit suggestions

**Layout**:
- **Header**:
  - "Today's Picks" title
  - Date selector (calendar icon)
  - Refresh button
  - Filter: Occasion dropdown

- **Weather Card**:
  - Location
  - Current temp + icon
  - High/Low
  - Condition (Sunny, Rain, etc.)

- **Outfit Cards** (vertical scroll, 3 per day):
  - Large outfit composite image
  - Title (AI-generated, e.g., "Cozy Casual")
  - Weather match score (icon + %)
  - Occasion tag
  - "View Details" button
  - Save icon (heart)
  - Share icon

**Interactions**:
- Tap card → Outfit Details (Screen 21)
- Tap refresh → Generate new picks
- Save → Saved outfits

---

## 21. Outfit Details View

**Purpose**: See outfit breakdown & options

**Layout**:
- **Hero Section**:
  - Full outfit composite image
  - Share button (top-right)
  - Save/unsave toggle

- **Outfit Info**:
  - Outfit name (editable)
  - Date created
  - Weather appropriateness
  - Occasion tags

- **Items Breakdown**:
  - Individual item cards (horizontal scroll):
    - Item photo
    - Category
    - Tap to view item details

- **Missing Items** (if any):
  - "Complete this look" section
  - Suggested items to buy
  - "Shop Similar" buttons → Shopping screen

- **Actions**:
  - "Wear Today" button → Mark as worn, share option
  - "Create Similar" → AI generates variations
  - "Edit Outfit" → Manual outfit builder

**Interactions**:
- Tap item → Item detail
- Shop → Affiliate shopping (Screen 22)
- Share → Share modal (Screen 26)

---

## 22. Shopping Screen

**Purpose**: Browse missing items & affiliate links

**Layout**:
- **Header**:
  - "Complete Your Wardrobe" title
  - Search bar
  - Filter icon

- **Context Card** (if from outfit):
  - "Missing for: [Outfit Name]"
  - Thumbnail of outfit
  - Needed item type

- **Product Grid** (2 columns):
  - Product cards:
    - Product image
    - Price
    - Store badge (Trendyol, Zara, etc.)
    - Similarity score (AI match %)
    - Favorite icon
  
- **Store Filter Tabs**:
  - All, Trendyol, Zara, H&M, Shein, ASOS

**Interactions**:
- Tap product → Product detail modal (Screen 23)
- Filters → Price, category, brand, size

---

## 23. Product Detail Modal

**Purpose**: Product info & affiliate link

**Layout**:
- Modal sheet (80% height):
  - Product image carousel
  - Product name
  - Price (with any discounts)
  - Store logo + name
  - AI match explanation
    - "92% match for your style"
    - "Perfect for casual weekends"
  - Size guide link
  - Color options
  - Product description
  
- **CTAs**:
  - "Shop Now" button (primary, opens affiliate link)
  - "Add to Wishlist" button
  - Close button

**Interactions**:
- Shop Now → Deep link to store app or web (tracks affiliate)
- Track click in analytics

---

## 24. Outfit Builder (Manual)

**Purpose**: Create custom outfit combinations

**Layout**:
- **Top Section**: Outfit preview
  - Composite view of selected items
  - Empty slots for unselected categories

- **Item Selection Area** (tabs):
  - Tabs: Tops, Bottoms, Shoes, Accessories, Outerwear
  - Horizontal scroll of items from wardrobe
  - Tap to add/remove from outfit

- **AI Suggestions**:
  - "AI Picks" badge on recommended combinations
  - "Try This" quick-add suggestions

- **Actions**:
  - Save Outfit
  - Share
  - Name Outfit (text input)

**Interactions**:
- Drag & drop items (optional)
- Tap to add
- AI real-time feedback on combinations

---

## 25. Saved Outfits Screen

**Purpose**: View outfit history & favorites

**Layout**:
- **Header**:
  - "My Outfits" title
  - Search
  - Sort dropdown (Recent, Favorites, Most Worn)

- **Filter Tabs**:
  - All
  - Favorites
  - By Occasion (Casual, Work, Evening, etc.)

- **Outfit Grid** (2 columns):
  - Outfit cards:
    - Composite image
    - Name
    - Date created
    - Times worn badge
    - Favorite star

**Interactions**:
- Tap outfit → Outfit Details (Screen 21)
- Long-press → Quick actions (Delete, Duplicate, Edit)

---

## 26. Share Modal

**Purpose**: Social media sharing with viral loop

**Layout**:
- Bottom sheet:
  - "Share Your Style" header
  - Outfit preview with watermark
  - Watermark position toggle (corner selection)
  
- **Platform Options**:
  - Instagram Stories (icon + label)
  - Instagram Feed
  - TikTok
  - Generic Share (Twitter, WhatsApp, etc.)
  
- **Customization**:
  - Add text overlay
  - Sticker selection
  - Background style

- **Deep Link Toggle**:
  - "Include app download link" (on by default)

**Interactions**:
- Select platform → Native share sheet
- Deep link tracks installs

**Technical**:
- Generates image with watermark
- Adds UTM parameters to deep link

---

## 27. Profile Screen

**Purpose**: User info & settings hub

**Layout**:
- **Profile Header**:
  - Avatar (editable)
  - Name
  - Member since date
  - Subscription badge (if premium)

- **Stats Row**:
  - Wardrobe Items: [X]
  - Outfits: [Y]
  - Saved: $[Z]

- **Menu Items**:
  - Edit Profile
  - My Subscription → Paywall (Screen 28)
  - Preferences
  - Notifications
  - Language (TR/EN/ES)
  - Help & Support
  - About
  - Logout

**Interactions**:
- Tap items → Respective screens
- Logout → Confirmation modal

---

## 28. Paywall Screen

**Purpose**: Monetization - subscription purchase

**Layout**:
- **Header**:
  - "Upgrade to Premium" title
  - Close button

- **Premium Features List**:
  - ✓ Ad-free experience
  - ✓ Unlimited outfit generations
  - ✓ Celebrity style packs
  - ✓ Premium outfit templates
  - ✓ Priority AI processing
  - ✓ Advanced analytics

- **Pricing Cards** (vertical):
  1. **Ad-Free Plan** - $4.99/month
     - Remove all ads
     - Most popular badge
  
  2. **Premium Outfit Pack** - $1.99/month
     - Weekly curated looks
     
  3. **Celebrity Style** - $2.99
     - Copy looks from Bella Hadid, etc.
     - One-time or subscription options

- **Actions**:
  - Subscribe button (per plan)
  - Restore Purchases link
  - Terms & conditions

**Interactions**:
- Subscribe → RevenueCat flow
- OS payment sheet
- Success → Update UI, close modal

--- 

## 29. Settings Screen

**Purpose**: App configuration

**Layout**:
- Grouped settings list:

**Account**:
- Email
- Phone number
- Password (if applicable)
- Connected accounts (Apple/Google)

**Preferences**:
- Style preferences (re-take quiz)
- Body type
- Favorite colors
- Default outfit occasion

**Notifications**:
- Daily outfit reminders (toggle)
- Shopping deals (toggle)
- Social activity (toggle)
- Time preferences

**App Settings**:
- Language
- Units (Metric/Imperial)
- Currency
- App theme (Light/Dark/Auto)

**Data & Privacy**:
- Download my data
- Delete account
- Privacy policy
- Terms of service

---

## 30. Notifications Screen

**Purpose**: Activity & updates feed

**Layout**:
- **Header**: "Notifications"
- **Filter Tabs**: All, Today, Unread

- **Notification List** (grouped by date):
  - Icon + message + timestamp
  - Types:
    - Outfit reminder: "Your looks for today are ready!"
    - Shopping: "20% off at Zara - check your saved items"
    - Social: "10 people loved your outfit!"
    - Update: "New celebrity styles available"
  
- **Actions**:
  - Swipe to delete
  - Tap to open related screen
  - Mark all as read

**Interactions**:
- Deep links to relevant screens

---

## 31. Search Screen

**Purpose**: Search wardrobe & outfits

**Layout**:
- **Search Bar** (auto-focus)
  - Voice search icon
  - Clear button

- **Recent Searches** (chips):
  - Tappable previous searches
  - Clear all option

- **Search Filters** (expandable):
  - Category
  - Color
  - Season
  - Brand

- **Results** (tabs):
  - Items (grid)
  - Outfits (grid)
  - Shopping (if enabled)

**Interactions**:
- Real-time search as typing
- Voice search → speech-to-text
- Tap result → Detail view

---

## 32. Edit Profile Screen

**Purpose**: Update user information

**Layout**:
- **Avatar Section**:
  - Large avatar
  - Change photo button
  - Remove photo option

- **Form Fields**:
  - Name
  - Email
  - Phone (read-only with change button)
  - Location
  - Bio (optional)

- **Preferences Quick Edit**:
  - Gender
  - Age range
  - Style tags

- **Actions**:
  - Save Changes button
  - Cancel button

**Interactions**:
- Avatar tap → Photo picker
- Save → Validate → Update Supabase → Success toast

---

## Design System Overview

### Color Palette
- **Primary**: Purple #8B5CF6
- **Secondary**: Pink #EC4899
- **Success**: Green #10B981
- **Warning**: Yellow #F59E0B
- **Error**: Red #EF4444
- **Background**: White #FFFFFF / Dark #1F2937
- **Text**: Gray-900 #111827 / Gray-100 #F3F4F6

### Typography
- **Font Family**: Inter (Google Fonts)
- **Headings**: 24-32px, Bold
- **Body**: 16px, Regular
- **Captions**: 14px, Medium

### Components
- **Buttons**: Rounded-lg, 48px height
- **Cards**: Rounded-xl, shadow-md  
- **Input Fields**: Rounded-lg, border-gray-300
- **Bottom Sheets**: Rounded-t-3xl

### Spacing
- Base unit: 4px
- Common: 8px, 12px, 16px, 24px, 32px

### Icons
- **Library**: Lucide Icons (consistent style)
- **Size**: 20px (small), 24px (default), 32px (large)

---

**Total Screens**: 32
**Platforms**: iOS + Android (Flutter adaptive design)
**Multi-language**: TR, EN, ES (i18n ready)
**Accessibility**: WCAG 2.1 AA compliant
