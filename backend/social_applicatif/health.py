from django.http import HttpResponse


def health(request):
    return HttpResponse("ok, ça farte !", content_type="text/plain", status=200)
