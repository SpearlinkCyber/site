---
layout: page
title: Home
---

<div class="homepage-hero">
  <img src="/assets/img/logos/spearlink-horizontal-small.png" alt="Spearlink Cyber" class="homepage-logo">
</div>

# Precision-focused security assessments. High-impact findings. Practical outcomes.

**Leveraging years of penetration testing and security consulting experience** with major Australian enterprises including financial services, healthcare, energy, and technology sectors. NT Proud Business focused on delivering practical security outcomes for Territory organisations.

---

## Core Capabilities

<div class="services-grid">
  <div class="service-card">
    <div class="service-icon">🎯</div>
    <h3>Penetration Testing</h3>
    <p>Find vulnerabilities before attackers do. Web applications, APIs, and infrastructure testing with clear remediation guidance.</p>
  </div>
  
  <div class="service-card">
    <div class="service-icon">☁️</div>
    <h3>Cloud Security Review</h3>
    <p>AWS, Azure, and GCP configuration assessment to identify misconfigurations and strengthen cloud security posture.</p>
  </div>
  
  <div class="service-card">
    <div class="service-icon">🔍</div>
    <h3>Security Consulting</h3>
    <p>Strategic security guidance including compliance readiness, risk assessment, and security program development.</p>
  </div>
</div>

---

## Latest Security Research

**Real-world insights from enterprise security engagements and independent research**

<div class="research-grid">
  <div class="research-card">
    <h4>Enterprise EDR Evasion Techniques</h4>
    <p>Advanced red team methodologies tested against enterprise-grade security solutions including DLL unhooking and AMSI bypass techniques.</p>
    <a href="/articles/enterprise-edr-evasion/" class="research-link">Read Article →</a>
  </div>
  
  <div class="research-card">
    <h4>Multi-Cloud Attack Vectors</h4>
    <p>Practical demonstration of AWS and Azure privilege escalation paths using real-world misconfigurations and IAM vulnerabilities.</p>
    <a href="/articles/" class="research-link">View All Articles →</a>
  </div>
  
  <div class="research-card">
    <h4>AWS Cross-Account Database Access</h4>
    <p>Infrastructure security insights for enterprise multi-account cloud architectures using VPC peering and IAM configuration.</p>
    <a href="/articles/aws-cross-account-access/" class="research-link">Read Article →</a>
  </div>
</div>

<div class="research-cta">
  <a href="/articles/" class="cta-button secondary">View All Technical Articles</a>
</div>

---

## Closing the Cybersecurity Gap in the Northern Territory

---

## Ready to Strengthen Your Security Posture?

<div class="cta-section">
  <a href="/contact/" class="cta-button">Get in Touch</a>
  <a href="/services/" class="cta-button secondary">View Capabilities</a>
</div>

<style>
.services-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 2rem;
  margin: 2rem 0;
}

.service-card {
  padding: 2rem;
  border: 1px solid #e5e7eb;
  border-radius: 12px;
  text-align: center;
  background: #ffffff;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.service-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(30, 58, 138, 0.15);
}

.service-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.service-card h3 {
  color: #1e3a8a;
  margin-bottom: 1rem;
  font-size: 1.25rem;
}

.cta-section {
  text-align: center;
  margin: 3rem 0;
}

.cta-button {
  display: inline-block;
  padding: 1rem 2rem;
  margin: 0 1rem;
  background: #1e3a8a;
  color: white;
  text-decoration: none;
  border-radius: 6px;
  font-weight: 600;
  transition: all 0.3s ease;
}

.cta-button:hover {
  background: #1e40af;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(30, 58, 138, 0.3);
  color: white;
}

.cta-button.secondary {
  background: transparent;
  color: #1e3a8a;
  border: 2px solid #1e3a8a;
}

.cta-button.secondary:hover {
  background: #1e3a8a;
  color: white;
}

.research-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
  margin: 2rem 0;
}

.research-card {
  padding: 1.5rem;
  background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);
  border: 2px solid #e0e7ff;
  border-radius: 12px;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.research-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(30, 58, 138, 0.15);
  border-color: #3b82f6;
}

.research-card h4 {
  color: #1e3a8a;
  margin-bottom: 1rem;
  font-size: 1.1rem;
  font-weight: 600;
}

.research-card p {
  color: #374151;
  font-size: 0.9rem;
  line-height: 1.5;
  margin-bottom: 1rem;
}

.research-link {
  color: #3b82f6;
  text-decoration: none;
  font-weight: 500;
  font-size: 0.9rem;
  transition: color 0.3s ease;
}

.research-link:hover {
  color: #1e40af;
}

.research-cta {
  text-align: center;
  margin: 2rem 0 0 0;
}

@media (max-width: 768px) {
  .services-grid {
    grid-template-columns: 1fr;
  }
  
  .cta-button {
    display: block;
    margin: 0.5rem auto;
    max-width: 200px;
  }
  
  .research-grid {
    grid-template-columns: 1fr;
    gap: 1.5rem;
  }
}
</style>
