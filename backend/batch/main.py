import os

from batch.api_client import YoutubeAPIClient
from db.client import DBClient


def handler(event, context):  # type: ignore
    api_key = os.environ.get("API_KEY", "")
    channel_id = os.environ.get("CHANNEL_ID", "")
    supabase_url = os.environ.get("SUPABASE_URL", "")
    supabase_key = os.environ.get("SUPABASE_KEY", "")

    api_client = YoutubeAPIClient(api_key)
    db_client = DBClient(supabase_url, supabase_key)

    latest_video_id = db_client.get_latest_video_id()
    playlist_id = api_client.get_playlist_id(channel_id)
    videos = api_client.get_videos(
        playlist_id, latest_video_id=latest_video_id, max_results=5, skip=True
    )
    print(f"Count: {len(videos)}")
    db_client.insert_videos(videos)
