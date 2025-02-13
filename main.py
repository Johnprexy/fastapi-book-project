from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Optional
from pydantic import BaseModel

app = FastAPI()

# Define Pydantic model for book data validation
class Book(BaseModel):
    id: int
    title: str
    author: str

# Sample books data 
books = [
    {"id": 1, "title": "Book 1", "author": "Author 1"},
    {"id": 2, "title": "Book 2", "author": "Author 2"},
    {"id": 3, "title": "Book 3", "author": "Author 3"}, 
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


@app.post("/api/v1/books", status_code=201)
async def create_book(book: Book):
    existing_book = next((b for b in books if b["id"] == book.id), None)
    if existing_book:
        raise HTTPException(status_code=400, detail="Book with this ID already exists")
    
    books.append(book.model_dump()) 
    return book

@app.put("/api/v1/books/{book_id}")
async def update_book(book_id: int, updated_book: Book):
    for i, book in enumerate(books):
        if book["id"] == book_id:
            books[i] = updated_book.model_dump() 
            return updated_book
    raise HTTPException(status_code=404, detail="Book not found")

@app.delete("/api/v1/books/{book_id}", status_code=204)
async def delete_book(book_id: int):
    global books
    books = [book for book in books if book["id"] != book_id]
    return
