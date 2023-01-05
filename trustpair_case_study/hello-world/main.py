import os

from fastapi import FastAPI

from app.api.api_v1.api import router as api_router
from mangum import Mangum

app = FastAPI()

stage = os.environ.get('STAGE', None)
openapi_prefix = f"/{stage}" if stage else "/"
app = FastAPI(title="MyAwesomeApp", openapi_prefix=openapi_prefix)

@app.get("/")
async def root():
    return {"message": "Hello World - Python powered !"}

app.include_router(api_router, prefix="/api/v1")
handler = Mangum(app)