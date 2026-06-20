import React, { useEffect, useState } from 'react';
import './App.css';

function App() {
  const [timestamp, setTimestamp] = useState('');

  useEffect(() => {
    setTimestamp(new Date().toLocaleString());
  }, []);

  const openDocs = () => {
    window.location.href = 'https://docs.microsoft.com/en-us/azure/static-web-apps/';
  };

  const openAzure = () => {
    window.location.href = 'https://portal.azure.com/';
  };

  return (
    <div className="container">
      <div className="logo">🚀</div>
      <h1>Azure Static Web App</h1>
      <p className="subtitle">Deployed with Terraform & GitHub Actions</p>

      <div className="status">
        <div className="status-item">
          <strong>Status</strong>
          <span>✅ Live & Running</span>
        </div>
        <div className="status-item">
          <strong>Infrastructure</strong>
          <span>Terraform IaC</span>
        </div>
        <div className="status-item">
          <strong>CI/CD</strong>
          <span>GitHub Actions</span>
        </div>
      </div>

      <div className="button-group">
        <button className="btn-primary" onClick={openDocs}>Documentation</button>
        <button className="btn-secondary" onClick={openAzure}>Azure Portal</button>
      </div>

      <div className="features">
        <h3>What You Have</h3>
        <ul className="feature-list">
          <li>Azure Static Web App Infrastructure</li>
          <li>Infrastructure as Code with Terraform</li>
          <li>Automated CI/CD with GitHub Actions</li>
          <li>Remote State Management</li>
          <li>Multi-environment Support</li>
          <li>Scalable and Secure Setup</li>
        </ul>
      </div>

      <div className="footer">
        <p>🎉 Deployment successful! Start building your app.</p>
        <p style={{ marginTop: '10px' }}>Last updated: <span id="timestamp">{timestamp}</span></p>
      </div>
    </div>
  );
}

export default App;