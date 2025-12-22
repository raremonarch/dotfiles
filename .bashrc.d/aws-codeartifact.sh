# AWS CodeArtifact utilities

# Used with data-engineering-deploy account that I do not currently have SSO access to, for installing DDK packages
function aws-codeartifact-login()
{
    export CODE_ARTIFACT_TOKEN=$(aws codeartifact get-authorization-token \
        --domain data-engineering \
        --domain-owner 323366779563 \
        --query authorizationToken \
        --output text)
    export PIP_EXTRA_INDEX_URL=https://aws:$CODE_ARTIFACT_TOKEN@data-engineering-323366779563.d.codeartifact.us-east-1.amazonaws.com/pypi/all-packages/simple/
    unset CODE_ARTIFACT_TOKEN
}
