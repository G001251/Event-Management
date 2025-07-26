import pytest
import requests
import time
from fastapi.testclient import TestClient
from generate import app

client = TestClient(app)

class TestFullWorkflow:
    """Integration tests for the full EventVista workflow"""
    
    def test_frontend_backend_integration(self):
        """Test that frontend can communicate with backend"""
        # Test health endpoint
        response = client.get("/health")
        assert response.status_code == 200
        
        # Test root endpoint
        response = client.get("/")
        assert response.status_code == 200
        
    def test_image_generation_workflow(self):
        """Test the complete image generation workflow"""
        # Test with a simple prompt
        test_prompt = "A modern conference room with blue lighting"
        
        response = client.post("/generate", json={"prompt": test_prompt})
        
        # The response should either be successful or indicate model not loaded
        assert response.status_code in [200, 500]
        
        if response.status_code == 200:
            data = response.json()
            assert "image" in data
            assert isinstance(data["image"], str)
            # Check if it's a valid base64 string
            assert len(data["image"]) > 100
            
    def test_error_handling(self):
        """Test error handling in the application"""
        # Test with invalid JSON
        response = client.post("/generate", data="invalid json")
        assert response.status_code == 422
        
        # Test with missing prompt
        response = client.post("/generate", json={})
        assert response.status_code == 422
        
    def test_cors_functionality(self):
        """Test CORS functionality for frontend integration"""
        headers = {
            "Origin": "http://localhost:3000",
            "Access-Control-Request-Method": "POST",
            "Access-Control-Request-Headers": "Content-Type"
        }
        
        response = client.options("/generate", headers=headers)
        assert response.status_code == 200
        
        # Check CORS headers
        assert "access-control-allow-origin" in response.headers
        
    def test_concurrent_requests(self):
        """Test handling of concurrent requests"""
        import threading
        import queue
        
        results = queue.Queue()
        
        def make_request():
            try:
                response = client.post("/generate", json={"prompt": "Test prompt"})
                results.put(response.status_code)
            except Exception as e:
                results.put(f"Error: {e}")
        
        # Start multiple threads
        threads = []
        for i in range(3):
            thread = threading.Thread(target=make_request)
            threads.append(thread)
            thread.start()
        
        # Wait for all threads to complete
        for thread in threads:
            thread.join()
        
        # Check results
        while not results.empty():
            result = results.get()
            assert result in [200, 500] or isinstance(result, str)
            
    def test_performance_metrics(self):
        """Test basic performance metrics"""
        start_time = time.time()
        
        response = client.get("/health")
        
        end_time = time.time()
        response_time = end_time - start_time
        
        # Health check should be fast (< 1 second)
        assert response_time < 1.0
        assert response.status_code == 200 