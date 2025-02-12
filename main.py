from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Optional
from pydantic import BaseModel

app = FastAPI()

# Sample books data
books = [
    {"id": 1, "title": "Book 1", "author": "Author 1"},
    {"id": 2, "title": "Book 2", "author": "Author 2"},
]

# CORS middleware configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "Welcome to the Book API"}

@app.get("/healthcheck")
async def health_check():
    """Checks if server is active."""
    return {"status": "active"}

@app.get("/api/v1/books/{book_id}")
async def get_book(book_id: int):
    book = next((book for book in books if book["id"] == book_id), None)
    if book is None:
        raise HTTPException(status_code=404, detail="Book not found")
    return book

@app.get("/api/v1/books")
async def list_books():
    return books