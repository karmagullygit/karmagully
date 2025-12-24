import requests
import json

# ------------------------------------------------------------------
# REPLACE THIS WITH YOUR ACTUAL API KEY
API_KEY = "AIzaSyALbGKZ-iAH9V0o6RPB14pQK42JHiC5blY" 
# ------------------------------------------------------------------

def test_imagen():
    if API_KEY == "YOUR_API_KEY_HERE":
        print("❌ Please edit this file and replace 'YOUR_API_KEY_HERE' with your actual Gemini API key.")
        return

    url = f"https://generativelanguage.googleapis.com/v1beta/models/imagen-3.0-generate-001:predict?key={API_KEY}"
    
    payload = {
        "instances": [
            {"prompt": "A small cute robot holding a flower, digital art"}
        ],
        "parameters": {
            "sampleCount": 1,
            "aspectRatio": "1:1"
        }
    }
    
    print(f"Testing API Key with Imagen endpoint...")
    
    try:
        response = requests.post(url, json=payload, headers={'Content-Type': 'application/json'})
        
        if response.status_code == 200:
            print("\n✅ SUCCESS! Your API key has access to Imagen.")
            print("The API returned a valid image response.")
        else:
            print(f"\n❌ FAILED. Status Code: {response.status_code}")
            print("Response body:")
            print(response.text)
            
            if response.status_code == 404:
                print("\nPossible reasons:")
                print("- The model 'imagen-3.0-generate-001' is not found.")
                print("- Your API key does not have access to this model.")
            elif response.status_code == 403:
                print("\nPossible reasons:")
                print("- API key is invalid.")
                print("- API key is restricted.")
                print("- Billing is not enabled (Imagen often requires a paid project).")

    except Exception as e:
        print(f"\n❌ Error running test: {e}")

if __name__ == "__main__":
    print("--- Imagen API Access Checker ---")
    try:
        import requests
        test_imagen()
    except ImportError:
        print("❌ The 'requests' library is not installed.")
        print("Please run: pip install requests")
