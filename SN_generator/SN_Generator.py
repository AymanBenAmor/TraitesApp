import hashlib
import uuid
import subprocess
import platform

def normalize_mac(mac):
    return mac.replace(":", "").replace("-", "").upper()

def hash_mac(mac, secret_key):
    mac = normalize_mac(mac)
    data = mac + secret_key
    hash_object = hashlib.sha512(data.encode())
    return hash_object.hexdigest()



# ------------------------
# Main
# ------------------------
mac = str(input("Enter the MAC address: "))
if mac is None:
    print("Could not get MAC address.")
    exit(1)

secret = "kjqshkdjshkdjhkuqhfkqdjhfkdhfkqdufhkdqjf"
hashed = hash_mac(mac, secret)

print("Generated SN:", hashed)

# Pause terminal before exit
input("\nPress Enter to exit...")


