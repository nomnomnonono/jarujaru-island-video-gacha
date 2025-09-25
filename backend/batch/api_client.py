import os

from googleapiclient.discovery import build  # type: ignore


class YoutubeAPIClient:
    def __init__(self, api_key: str) -> None:
        self.youtube = build("youtube", "v3", developerKey=api_key)

    def get_playlist_id(self, channel_id: str) -> str:
        channel_response = (
            self.youtube.channels()
            .list(part="snippet,contentDetails", id=channel_id)
            .execute()
        )

        uploads_playlist_id = channel_response["items"][0]["contentDetails"][
            "relatedPlaylists"
        ]["uploads"]

        return uploads_playlist_id

    def get_videos(
        self, playlist_id: str, latest_video_id=None, max_results=50, skip=False
    ) -> list[dict[str, str]]:
        videos = []
        next_page_token = None

        while True:
            playlist_response = (
                self.youtube.playlistItems()
                .list(
                    part="snippet",
                    playlistId=playlist_id,
                    maxResults=max_results,
                    pageToken=next_page_token,
                )
                .execute()
            )

            for item in playlist_response["items"]:
                snippet = item["snippet"]
                video_id = snippet["resourceId"]["videoId"]
                if video_id == latest_video_id:
                    break

                videos.append(
                    {
                        "video_id": video_id,
                        "title": snippet["title"],
                        "published_at": snippet["publishedAt"][:10],
                        "thumbnail": snippet["thumbnails"]["high"]["url"],
                        "url": f"https://www.youtube.com/watch?v={video_id}",
                    }
                )

            # 次のページがなければ終了
            next_page_token = playlist_response.get("nextPageToken")
            if not next_page_token or skip:
                break

        return videos


if __name__ == "__main__":
    api_key = os.environ.get("API_KEY", "")
    channel_id = os.environ.get("CHANNEL_ID", "")
    client = YoutubeAPIClient(api_key)
    playlist_id = client.get_playlist_id(channel_id)
    videos = client.get_videos(playlist_id, max_results=5, skip=True)
    for video in videos:
        print(video)
        print("-" * 50)
