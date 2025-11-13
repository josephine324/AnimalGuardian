from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
from django.conf import settings
import os
import uuid
from datetime import datetime


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def upload_file(request):
    """Upload a file (image, video, or audio)."""
    
    if 'file' not in request.FILES:
        return Response({
            'error': 'No file provided.'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    file = request.FILES['file']
    file_type = request.data.get('type', 'image')  # image, video, audio
    related_object = request.data.get('related_object', '')  # livestock, case, etc.
    related_id = request.data.get('related_id', '')
    
    # Validate file type
    allowed_image_types = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
    allowed_video_types = ['video/mp4', 'video/avi', 'video/mov', 'video/quicktime']
    allowed_audio_types = ['audio/mpeg', 'audio/mp3', 'audio/wav', 'audio/ogg']
    
    if file_type == 'image' and file.content_type not in allowed_image_types:
        return Response({
            'error': f'Invalid image type. Allowed: {", ".join(allowed_image_types)}'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    if file_type == 'video' and file.content_type not in allowed_video_types:
        return Response({
            'error': f'Invalid video type. Allowed: {", ".join(allowed_video_types)}'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    if file_type == 'audio' and file.content_type not in allowed_audio_types:
        return Response({
            'error': f'Invalid audio type. Allowed: {", ".join(allowed_audio_types)}'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    # Generate unique filename
    file_ext = os.path.splitext(file.name)[1]
    unique_filename = f"{uuid.uuid4()}{file_ext}"
    
    # Create directory structure: media/files/{type}/{year}/{month}/
    now = datetime.now()
    directory = f"files/{file_type}/{now.year}/{now.month:02d}/"
    file_path = os.path.join(directory, unique_filename)
    
    # Save file
    saved_path = default_storage.save(file_path, ContentFile(file.read()))
    file_url = request.build_absolute_uri(settings.MEDIA_URL + saved_path)
    
    # Get file size
    file_size = default_storage.size(saved_path)
    
    return Response({
        'id': str(uuid.uuid4()),
        'filename': file.name,
        'file_url': file_url,
        'file_path': saved_path,
        'file_size': file_size,
        'content_type': file.content_type,
        'type': file_type,
        'related_object': related_object,
        'related_id': related_id,
        'uploaded_at': datetime.now().isoformat(),
    }, status=status.HTTP_201_CREATED)

