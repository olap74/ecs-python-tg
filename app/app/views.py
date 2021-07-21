from app import app
import boto3
import json
import os
from flask import render_template

version = os.environ.get('VERSION')

@app.route('/')
def template():
    client = boto3.client('s3')
    buckets = client.list_buckets()
    buckets_data = buckets["Buckets"]

    title="Buckets list"
    # data = json.dumps(buckets_data, indent=4, sort_keys=True, default=str)
    data = buckets_data
    return render_template('home.html', title=title, data=data, version=version)