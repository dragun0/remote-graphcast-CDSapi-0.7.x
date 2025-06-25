# Remote Graphcast for CDS API 0.7.x

**A patched and updated Python package for remote execution of GraphCast forecasts using the updated Copernicus Climate Data Store (CDS) API (v0.7.x compatible)**

## Overview

This repository provides an updated interface for executing [GraphCast](https://github.com/deepmind/graphcast) weather forecasts on GPU cloud infrastructure. It is a forked and modified version of the original [`remote-graphcast`](https://pypi.org/project/remote-graphcast/) package by Louka Ewington-Pitsos, adapted to work with the **new Copernicus CDS API** and endpoint structure (introduced in July 2024).

The modifications ensure continued functionality of the remote forecasting pipeline following the deprecation of the legacy `cdsapi` and associated changes to the CDS URL and authentication structure.

---

## Key Features

- Updated for compatibility with the post-2024 CDS API and authentication system
- Revised Docker environment with new dependency management
- Remote GPU forecast execution using [RunPod.io](https://runpod.io)
- Forecast outputs stored directly to AWS S3
- Fully automated: init → run → store → shutdown

---

## Credits

The original work was developed by [Louka Ewington-Pitsos](https://github.com/Lewington-pitsos). All credit of the work goes to him. This fork is intended as a solution for continued GraphCast model usage with `remote-graphcast` after decomissioning of the legacy `cdsapi`.

---

Run [graphcast](https://github.com/google-deepmind/graphcast) on a [runpod](https://runpod.io/) GPU server. Output is saved to [s3](https://aws.amazon.com/pm/serv-s3/). Shouldn't cost more than $0.6 USD for a 10 day forcast.

## Order of operations

1. Your input is validated
2. A secure runpod GPU pod is spun up on your runpod account
3. Graphcast is installed into that gpu and forecasts of your chosen length are generated for each timestamp, this takes around 10 minutes for a 10 day forcast
4. These forecasts are saved to your chosen s3 bucket, roughly **6.5GB for 10 days** of forecast
5. The runpod pod is terminated
6. The program exits

## Requirements

- python 3.8+ and pip
- [cds.climate](https://cds.climate.copernicus.eu/how-to-api) credentials
- an [AWS](https://aws.amazon.com/console/) s3 bucket, free tier should be fine
- S3 credentials to go with the bucket
- [Runpod](https://www.runpod.io/) credentials

## Installation

`pip install git+https://github.com/dragun0/remote-graphcast-CDSapi-0.7.x.git`

## Example Code

```python

from remote_graphcast import remote_cast

remote_cast(
	aws_access_key_id='YOUR_AWS_ACCESS_KEY_ID',
	aws_secret_access_key='YOUR_AWS_SECRET_ACCESS_KEY',
	aws_bucket='YOUR_AWS_BUCKET_NAME',
	cds_url='https://cds.climate.copernicus.eu/api/v2', # this is probably your CDS URL
	cds_key='YOUR_CDS_KEY',
	forcast_list="[{'start': '2023122518', 'hours_to_forcast': 48}]",
	# dates to forcast from, note the weird quasi-JSON format, of this string, use single quotes instead of double quotes
	# select a date in the future and it will raise an error without spinning up anything
	runpod_key='YOUR_RUNPOD_KEY',
	gpu_type_id="NVIDIA A100-SXM4-80GB", # graphcast needs at least 61GB GPU ram (unless you want to quantize)
	container_disk_in_gb=50, # you'll need around 40GB per 10 day forcast + a healthy 10GB buffer
)

# internally this function will keep polling the pod it spins up and the s3 bucket until it sees that all forcasts
# are complete, then it will return

```

## Warning

In order to make predictions graphcast must request ERA5 reanalysis data from the European Center for Medium Range Weather Forcasts (ECMWF). Usually the download completes in < 2 minutes. However, if their servers are busy your request will be [put in a queue](https://confluence.ecmwf.int/display/UDOC/My+request+is+queued+for+a+long+time+-+Web+API+FAQ). You can view all your open requests [here](https://cds.climate.copernicus.eu/cdsapp#!/yourrequests). Until your request is granted is granted, the graphcast runpod server will be waiting idly (costing you money). This process has taken me > 1 hour in the past.

You can also check your progress by viewing the runpod logs.
