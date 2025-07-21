---
title: Insights
icon: fas fa-lightbulb
order: 3
---

# Security Insights

Stay informed about the latest cybersecurity trends, threats, and best practices affecting Australian organisations.

{% if site.posts.size > 0 %}
  <div class="post-grid">
    {% for post in site.posts %}
      <article class="insight-card">
        <h2><a href="{{ post.url | relative_url }}">{{ post.title }}</a></h2>
        <p class="post-meta">
          <time datetime="{{ post.date | date_to_xmlschema }}">{{ post.date | date: "%B %d, %Y" }}</time>
          {% if post.categories.size > 0 %}
            • 
            {% for category in post.categories %}
              <span class="category">{{ category }}</span>{% unless forloop.last %}, {% endunless %}
            {% endfor %}
          {% endif %}
        </p>
        {% if post.excerpt %}
          <p class="excerpt">{{ post.excerpt | strip_html | truncatewords: 30 }}</p>
        {% endif %}
        <a href="{{ post.url | relative_url }}" class="read-more">Read more →</a>
      </article>
    {% endfor %}
  </div>
{% else %}
  <div class="no-posts">
    <p>Security insights coming soon. Check back for the latest cybersecurity analysis and best practices.</p>
  </div>
{% endif %}

<style>
.post-grid {
  display: grid;
  gap: 2rem;
  max-width: 800px;
}

.insight-card {
  padding: 1.5rem;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  background: #ffffff;
  transition: box-shadow 0.3s ease;
}

.insight-card:hover {
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
}

.insight-card h2 {
  margin-bottom: 0.5rem;
  font-size: 1.25rem;
}

.insight-card h2 a {
  color: #1e3a8a;
  text-decoration: none;
}

.insight-card h2 a:hover {
  text-decoration: underline;
}

.post-meta {
  color: #6b7280;
  font-size: 0.875rem;
  margin-bottom: 1rem;
}

.category {
  background: #dbeafe;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 0.75rem;
  color: #1e40af;
}

.excerpt {
  color: #374151;
  line-height: 1.6;
  margin-bottom: 1rem;
}

.read-more {
  color: #1e3a8a;
  text-decoration: none;
  font-weight: 500;
}

.read-more:hover {
  text-decoration: underline;
}

.no-posts {
  text-align: center;
  padding: 3rem;
  color: #6b7280;
}
</style>
