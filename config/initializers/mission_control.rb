# frozen_string_literal: true

# Mission Control - Jobs configuration
# Configure authentication for the Mission Control dashboard.
# In production, set MISSION_CONTROL_HTTP_USER and MISSION_CONTROL_HTTP_PASSWORD
# environment variables to secure the dashboard.
MissionControl::Jobs.http_basic_auth_enabled = false
