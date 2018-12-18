package vaultlib

import (
	"encoding/json"

	"github.com/pkg/errors"
)

type VaultAuth struct {
	Auth struct {
		ClientToken string   `json:"client_token"`
		Accessor    string   `json:"accessor"`
		Policies    []string `json:"policies"`
		Metadata    struct {
			RoleName string `json:"role_name"`
		} `json:"metadata"`
		LeaseDuration int    `json:"lease_duration"`
		Renewable     bool   `json:"renewable"`
		EntityID      string `json:"entity_id"`
	} `json:"auth"`
}

//SetTokenFromAppRole get the token from Vault and set it in the client
func (c *VaultClient) SetTokenFromAppRole() error {
	if c.Config.AppRoleCredentials.RoleID == "" {
		return errors.New("No credentials provided")
	}

	var req request
	req.Method = "POST"
	req.URL = c.Address
	req.URL.Path = "/v1/auth/approle/login"
	err := req.prepareRequest()
	if err != nil {
		return err
	}
	req.setJSONBody(c.Config.AppRoleCredentials)
	resp, err := req.execute(c.HTTPClient)
	if err != nil {
		return errors.Wrap(errors.WithStack(err), errInfo())
	}
	var vaultAuth VaultAuth
	jsonErr := json.Unmarshal(resp.Auth, &vaultAuth)
	if jsonErr != nil {
		return errors.Wrap(errors.WithStack(err), errInfo())
	}
	c.Token = vaultAuth.Auth.ClientToken

	return nil
}
