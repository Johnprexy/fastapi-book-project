from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI, HTTPException

from api.router import api_router
from core.config import settings

app = FastAPI()

books = [
    {"id": 1, "title": "Book 1", "author": "Author 1"},
    {"id": 2, "title": "Book 2", "author": "Author 2"},
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(api_router, prefix=settings.API_PREFIX)

@app.get("/api/v1/books/{book_id}")
def get_book_by_id(book_id: int):
    for book in books:
        if book["id"] == book_id:
            return book
    raise HTTPException(status_code=404, detail="Book not found")

@app.get("/healthcheck")
async def health_check():
    """Checks if server is active."""
    return {"status": "active"}
