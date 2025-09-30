import os

from db.client import DBClient
from fastapi import FastAPI, Form, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from mangum import Mangum

app = FastAPI()
templates = Jinja2Templates(directory="templates")

bucket_name = os.environ.get("BUCKET_NAME", "")
region = os.environ.get("REGION", "")
app.add_middleware(
    CORSMiddleware,
    allow_origins=[f"https://{bucket_name}.s3.{region}.amazonaws.com"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

supabase_url = os.environ.get("SUPABASE_URL", "")
supabase_key = os.environ.get("SUPABASE_KEY", "")
db_client = DBClient(supabase_url, supabase_key)


@app.get("/")
async def health_check():
    return {"message": "success"}


@app.get("/random", response_class=HTMLResponse)
async def random(request: Request):
    results = db_client.get_videos(limit=10)

    return templates.TemplateResponse(
        "results.html",
        {"request": request, "results": results},
    )


@app.post("/search", response_class=HTMLResponse)
async def search(
    request: Request,
    limit: int = Form(""),
    min_published_at: str = Form(""),
    max_published_at: str = Form(""),
):
    results = db_client.get_videos(
        limit=limit,
        min_published_at=min_published_at,
        max_published_at=max_published_at,
    )

    return templates.TemplateResponse(
        "results.html",
        {"request": request, "results": results},
    )


handler = Mangum(app)
