import requests
import re
import sys

def move_binary(os_choice):
    import os
    if os_choice == 'win':
        os.replace("stribog/stribog.exe", "c:/stribog.exe")
    else:
        os.replace('stribog/stribog', '/root/stribog')

def extract_zip():
    import zipfile
    with zipfile.ZipFile("stribog.zip", 'r') as zip_ref:
        zip_ref.extractall("stribog")

def download_binary(url, os_choice):
    file = requests.get(url)
    with open('stribog.zip', "wb") as z:
        z.write(file.content)
        extract_zip()
        move_binary(os_choice)


zipname_win = re.compile(r'^stribog_v(\d+\.\d+\.\d+)_x86_64-pc-windows-gnu\.zip$')
zipname_lin = re.compile(r'^stribog_v(\d+\.\d+\.\d+)_x86_64-unknown-linux-musl\.zip$')

x = requests.get('https://api.github.com/repos/markojerkic/stribog/releases/latest')
os_choice = sys.argv[-1]

zipname = zipname_win if os_choice == 'win' else zipname_lin

for asset in x.json()['assets']:
    asset_name = asset['name']
    match = zipname.match(asset_name)
    if match != None:
        download_url = asset['browser_download_url']
        download_binary(download_url, os_choice)
