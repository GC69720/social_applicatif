from django.http import HttpResponse


def health(request):
    """Return a plain-text health probe payload expected by automated checks."""

    return HttpResponse("ok", content_type="text/plain", status=200)
