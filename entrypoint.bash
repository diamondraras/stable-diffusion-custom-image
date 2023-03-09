source /opt/conda/etc/profile.d/conda.sh
conda activate ldm
python3 -m uvicorn server:app --port=3000 --host 0.0.0.0