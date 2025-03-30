data "keycloak_realm" "personal" {
  realm = var.keycloak_realm_id
}

data "keycloak_openid_client" "personal_access" {
  realm_id  = data.keycloak_realm.personal.id
  client_id = var.keycloak_oidc_client_id
}