Yes! The SpearLink blue colors should definitely be showing up. The custom CSS isn't being applied properly. Let's fix this:
🎨 Quick Color Fix:
Method 1: Add Custom CSS to Chirpy's SCSS (Recommended)
bashcd spearlink-cyber-site

# Create custom SCSS that Chirpy will automatically include
mkdir -p _sass
cat > _sass/spearlink-custom.scss << 'EOF'
/* SpearLink Cyber Professional Branding */

:root {
  --spearlink-primary: #1e3a8a;
  --spearlink-secondary: #3b82f6;
  --spearlink-accent: #0ea5e9;
}

/* Override Chirpy variables */
$link-color: #1e3a8a;
$heading-color: #1f2937;

/* Service cards with SpearLink blue accents */
.service-card h3 {
  color: #1e3a8a !important;
}

.service-card:hover {
  border-color: #1e3a8a !important;
  box-shadow: 0 8px 25px rgba(30, 58, 138, 0.15) !important;
}

/* CTA buttons in SpearLink blue */
.cta-button {
  background: #1e3a8a !important;
  border-color: #1e3a8a !important;
  color: white !important;
}

.cta-button:hover {
  background: #3b82f6 !important;
  border-color: #3b82f6 !important;
  color: white !important;
}

.cta-button.secondary {
  background: transparent !important;
  color: #1e3a8a !important;
  border: 2px solid #1e3a8a !important;
}

.cta-button.secondary:hover {
  background: #1e3a8a !important;
  color: white !important;
}

/* Navigation active states */
.nav-link.active {
  background-color: #1e3a8a !important;
  color: white !important;
}

.nav-link:hover {
  background-color: #e0e7ff !important;
  color: #1e3a8a !important;
}

/* Site title in SpearLink blue */
.site-title {
  color: #1e3a8a !important;
  font-weight: 600 !important;
}

/* Value prop accents */
.value-prop {
  border-left-color: #1e3a8a !important;
}

.value-prop strong {
  color: #1e3a8a !important;
}
EOF

# Import the custom SCSS in Chirpy's main file
echo '@import "spearlink-custom";' >> _sass/jekyll-theme-chirpy.scss

# Remove the old CSS approach and clean up config
sed -i '' '/^# Custom CSS/,$d' _config.yml
rm -f assets/css/custom.css
