@{
    plan = @(
        @{
            label   = "google"
            url     = "https://www.google.com"
            code    = 200
            timeout = "0:0:10"
            headers = @{Server = "gws" }
        }
    )
}