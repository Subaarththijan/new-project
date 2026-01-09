# Simple PowerShell Web Server
$port = 8080
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://*:$port/")
try {
    $listener.Start()
    Write-Host "Server started at http://192.168.8.186:$port/"
    Write-Host "Press Ctrl+C to stop the server."

    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $urlPath = $request.Url.LocalPath
        if ($urlPath -eq "/") { $urlPath = "/index.html" }
        
        $filePath = Join-Path (Get-Location) $urlPath.Replace("/", "\")
        
        if (Test-Path $filePath -PathType Leaf) {
            $buffer = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentLength64 = $buffer.Length
            
            # Simple content-type mapping
            $extension = [System.IO.Path]::GetExtension($filePath).ToLower()
            $contentType = switch ($extension) {
                ".html" { "text/html" }
                ".css" { "text/css" }
                ".js" { "application/javascript" }
                ".jpg" { "image/jpeg" }
                ".jpeg" { "image/jpeg" }
                ".png" { "image/png" }
                ".mp3" { "audio/mpeg" }
                default { "application/octet-stream" }
            }
            $response.ContentType = $contentType
            
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        } else {
            $response.StatusCode = 404
        }
        $response.Close()
    }
} finally {
    $listener.Stop()
}
