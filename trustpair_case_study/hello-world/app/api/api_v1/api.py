from fastapi import APIRouter

from .endpoints import demo

router = APIRouter()
router.include_router(demo.router, prefix="/trustpair", tags=["demo"])