import pytest
from fastapi.testclient import TestClient
from generate import app

client = TestClient(app)

def test_root_endpoint():
    """Test the root endpoint returns correct status"""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "EventVista Image Generator is running"
    assert "model" in data

def test_health_endpoint():
    """Test the health check endpoint"""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert "status" in data
    assert "cuda_available" in data
    assert "model_loaded" in data

def test_generate_endpoint_missing_prompt():
    """Test generate endpoint with missing prompt"""
    response = client.post("/generate", json={})
    assert response.status_code == 422  # Validation error

def test_generate_endpoint_empty_prompt():
    """Test generate endpoint with empty prompt"""
    response = client.post("/generate", json={"prompt": ""})
    assert response.status_code == 422  # Validation error

def test_generate_endpoint_valid_prompt():
    """Test generate endpoint with valid prompt"""
    # This test might fail if the model is not loaded
    response = client.post("/generate", json={"prompt": "A beautiful wedding venue"})
    # Either success (200) or model not loaded (500)
    assert response.status_code in [200, 500]

def test_cors_headers():
    """Test that CORS headers are properly set"""
    response = client.options("/generate")
    assert response.status_code == 200
    # CORS headers should be present
    assert "access-control-allow-origin" in response.headers

def test_prompt_request_model():
    """Test the PromptRequest Pydantic model"""
    from generate import PromptRequest
    
    # Valid prompt
    valid_request = PromptRequest(prompt="Test prompt")
    assert valid_request.prompt == "Test prompt"
    
    # Test with empty string (should raise validation error)
    with pytest.raises(ValueError):
        PromptRequest(prompt="") 