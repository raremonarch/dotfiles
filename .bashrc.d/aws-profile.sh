# AWS profile management

# Current AWS Profile (auto-updated by aws-login-* functions)
export AWS_PROFILE=novelist-deploy-pipelineuser

function aws-login-novelist-deploy-pipelineuser() {
  local profile="novelist-deploy-pipelineuser"
  aws sso login --profile "$profile" || return 1
  aws-set-profile "$profile"
}

# Manually set profile (also persists to file)
function aws-set-profile() {
  local profile_name="$1"

  if [[ -z "$profile_name" ]]; then
    echo "Usage: aws-set-profile <profile-name>"
    return 1
  fi

  # Update this file to persist the profile across terminals
  sed -i "s/^export AWS_PROFILE=.*/export AWS_PROFILE=$profile_name/" ~/.bashrc.d/aws-profile.sh

  # Export for current session
  export AWS_PROFILE="$profile_name"

  echo "✓ Switched to profile: $profile_name"
}
