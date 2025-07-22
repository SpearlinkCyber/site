ls -la index.*

# Remove the conflicting index.html (we want to keep our custom index.md)
rm -f index.html

# Also clean up any potential SCSS import issues
# Check if the jekyll-theme-chirpy.scss file exists where we tried to modify it
ls -la _sass/jekyll-theme-chirpy.scss

# If it doesn't exist, we need to create it or use a different approach
if [[ ! -f "_sass/jekyll-theme-chirpy.scss" ]]; then
    echo "SCSS file doesn't exist, using simpler CSS approach..."
    
    # Remove the SCSS attempt
    rm -rf _sass/
    
    # Use the direct CSS method instead
    mkdir -p _includes
    cat > _includes/head-custom.html << 'EOF'
<style>
/* SpearLink Cyber Professional Colors */
.service-card h3 {
  color: #1e3a8a !important;
}

.service-card:hover {
  border-color: #1e3a8a !important;
  box-shadow: 0 8px 25px rgba(30, 58, 138, 0.15) !important;
}

.cta-button {
  background: #1e3a8a !important;
  color: white !important;
  border: none !important;
}

.cta-button:hover {
  background: #3b82f6 !important;
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

.nav-link.active {
  background-color: #1e3a8a !important;
  color: white !important;
}

.nav-link:hover {
  background-color: #e0e7ff !important;
  color: #1e3a8a !important;
}

.site-title {
  color: #1e3a8a !important;
  font-weight: 600 !important;
}

.value-prop {
  border-left: 4px solid #1e3a8a !important;
}

.value-prop strong {
  color: #1e3a8a !important;
}

/* Sidebar professional styling */
#sidebar {
  background-color: #f8fafc !important;
}

.site-subtitle {
  color: #6b7280 !important;
}
</style>
EOF
fi

# Test the build again
bundle exec jekyll build
