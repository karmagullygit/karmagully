import requests
import json

API_KEY = "AIzaSyCK5bwqpT7IFxYS-XZJjyAe-W5qUc5DXXM"

def list_models():
    url = f"https://generativelanguage.googleapis.com/v1beta/models?key={API_KEY}"
    try:
        response = requests.get(url)
        if response.status_code == 200:
            models = response.json().get('models', [])
            print(f"Found {len(models)} models.")
            for m in models:
                if 'generateContent' in m.get('supportedGenerationMethods', []):
                    print(f"- {m['name']} (Content Generation)")
                if 'predict' in m.get('supportedGenerationMethods', []):
                    print(f"- {m['name']} (Predict)")
        else:
            print(f"Error listing models: {response.status_code}")
            print(response.text)
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    list_models()