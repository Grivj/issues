ExUnit.start()

# Set up Mox for mocking
Mox.defmock(Issues.MockHttpClient, for: Issues.HttpClient)
