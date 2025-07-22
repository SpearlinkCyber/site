# Create a more comprehensive color scheme with more blue "wash"
cat > _includes/head-custom.html << 'EOF'
<style>
/* SpearLink Cyber - More Blue Throughout */

/* SIDEBAR - Force SpearLink blue title */
#sidebar .site-title,
#sidebar .site-title a,
.site-title,
.site-title a {
  color: #1e3a8a !important;
  font-weight: 600 !important;
}

/* Sidebar background with subtle blue tint */
#sidebar {
  background: linear-gradient(135deg, #f8fafc 0%, #e0e7ff 100%) !important;
  border-right: 2px solid #e0e7ff !important;
}

/* Navigation - More blue presence */
.nav-link {
  transition: all 0.3s ease !important;
}

.nav-link:hover {
  background-color: #dbeafe !important;
  color: #1e3a8a !important;
  border-radius: 6px !important;
}

.nav-link.active {
  background: linear-gradient(135deg, #1e3a8a, #3b82f6) !important;
  color: white !important;
  border-radius: 6px !important;
}

/* Main content area - subtle blue accents */
.main-content {
  background: linear-gradient(180deg, #ffffff 0%, #f8fafc 100%) !important;
}

/* Service cards - more blue styling */
.service-card {
  border: 2px solid #e5e7eb !important;
  background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%) !important;
  transition: all 0.3s ease !important;
}

.service-card:hover {
  border-color: #3b82f6 !important;
  box-shadow: 0 12px 30px rgba(30, 58, 138, 0.2) !important;
  background: linear-gradient(135deg, #ffffff 0%, #dbeafe 100%) !important;
}

.service-card h3 {
  color: #1e3a8a !important;
  font-weight: 600 !important;
}

/* Service icons with blue background */
.service-icon {
  background: linear-gradient(135deg, #dbeafe, #bfdbfe) !important;
  border-radius: 50% !important;
  width: 80px !important;
  height: 80px !important;
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
  margin: 0 auto 1rem auto !important;
  box-shadow: 0 4px 12px rgba(30, 58, 138, 0.15) !important;
}

/* Value propositions - blue accents */
.value-prop {
  border-left: 4px solid #1e3a8a !important;
  background: linear-gradient(135deg, #f8fafc 0%, #e0e7ff 100%) !important;
  border-radius: 8px !important;
}

.value-prop strong {
  color: #1e3a8a !important;
  font-size: 1.1rem !important;
}

/* CTA buttons - enhanced styling */
.cta-button {
  background: linear-gradient(135deg, #1e3a8a, #3b82f6) !important;
  color: white !important;
  border: none !important;
  box-shadow: 0 4px 15px rgba(30, 58, 138, 0.3) !important;
  transition: all 0.3s ease !important;
}

.cta-button:hover {
  background: linear-gradient(135deg, #3b82f6, #0ea5e9) !important;
  transform: translateY(-3px) !important;
  box-shadow: 0 8px 25px rgba(30, 58, 138, 0.4) !important;
  color: white !important;
}

.cta-button.secondary {
  background: transparent !important;
  color: #1e3a8a !important;
  border: 2px solid #1e3a8a !important;
  box-shadow: 0 4px 15px rgba(30, 58, 138, 0.15) !important;
}

.cta-button.secondary:hover {
  background: linear-gradient(135deg, #1e3a8a, #3b82f6) !important;
  color: white !important;
  box-shadow: 0 8px 25px rgba(30, 58, 138, 0.4) !important;
}

/* Headings with blue accents */
h1, h2, h3 {
  color: #1f2937 !important;
}

h1::after {
  content: '';
  display: block;
  width: 60px;
  height: 3px;
  background: linear-gradient(135deg, #1e3a8a, #3b82f6);
  margin: 0.5rem 0;
}

/* Links throughout site */
a {
  color: #1e3a8a !important;
  transition: color 0.3s ease !important;
}

a:hover {
  color: #3b82f6 !important;
}

/* Subtle blue footer accents */
.footer {
  background: linear-gradient(135deg, #f8fafc 0%, #e0e7ff 100%) !important;
  border-top: 2px solid #e0e7ff !important;
}

/* Search box with blue accent */
#search-input {
  border: 2px solid #e5e7eb !important;
  transition: border-color 0.3s ease !important;
}

#search-input:focus {
  border-color: #3b82f6 !important;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1) !important;
}

/* Top navigation bar */
#topbar {
  background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%) !important;
  border-bottom: 2px solid #e0e7ff !important;
}
</style>
EOF

# Test the enhanced blue theme
bundle exec jekyll build && bundle exec jekyll serve
