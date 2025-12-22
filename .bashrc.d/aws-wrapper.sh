# AWS CLI wrapper that auto-appends --profile

aws() {
    if [[ -n "$AWS_PROFILE" ]] && [[ ! " $* " =~ " --profile " ]]; then
        echo "→ Using AWS_PROFILE: $AWS_PROFILE" >&2
        command aws --profile "$AWS_PROFILE" "$@"
    else
        command aws "$@"
    fi
}
