# Update the CSS to force sidebar title color
cat >> _includes/head-custom.html << 'EOF'

/* Fix sidebar title color */
#sidebar .site-title,
#sidebar .site-title a {
  color: #1e3a8a !important;
}

/* Ensure navigation icons use SpearLink blue when active */
.nav-link.active i {
  color: white !important;
}
EOF

# Test the change
bundle exec jekyll build && bundle exec jekyll serve
