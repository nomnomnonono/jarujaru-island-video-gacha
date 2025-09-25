import os
import random

from supabase import Client, create_client


class DBClient:
    def __init__(self, supabase_url: str, supabase_key: str) -> None:
        self.supabase: Client = create_client(supabase_url, supabase_key)

    def _get_ids(self, min_published_at: str, max_published_at: str) -> list[str]:
        if min_published_at == "":
            min_published_at = "0000-00-00"
        if max_published_at == "":
            max_published_at = "9999-99-99"

        result = (
            self.supabase.table("videos")
            .select("id")
            .gte("published_at", min_published_at)
            .lte("published_at", max_published_at)
            .execute()
        )
        ids = [row["id"] for row in result.data]
        return ids

    def get_latest_video_id(self) -> str | None:
        result = (
            self.supabase.table("videos")
            .select("video_id")
            .order("published_at", desc=True)
            .limit(1)
            .execute()
        )

        video_id: str | None = (
            None if len(result.data) == 0 else result.data[0]["video_id"]
        )
        return video_id

    def insert_videos(self, videos: list[dict[str, str]]) -> None:
        _ = self.supabase.table("videos").insert(videos).execute()

    def get_videos(
        self, limit=5, min_published_at="", max_published_at=""
    ) -> list[dict[str, str]]:
        ids = self._get_ids(
            min_published_at=min_published_at, max_published_at=max_published_at
        )
        random_ids = random.sample(ids, min(len(ids), limit))

        result = (
            self.supabase.table("videos").select("*").in_("id", random_ids).execute()
        )

        return result.data


if __name__ == "__main__":
    supabase_url = os.environ.get("SUPABASE_URL", "")
    supabase_key = os.environ.get("SUPABASE_KEY", "")
    client = DBClient(supabase_url, supabase_key)
    latest_video_id = client.get_latest_video_id()
    print(latest_video_id)
