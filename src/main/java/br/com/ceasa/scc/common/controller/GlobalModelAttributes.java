package br.com.ceasa.scc.common.controller;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import java.util.Collection;
import java.util.Map;

@ControllerAdvice
public class GlobalModelAttributes {

    @ModelAttribute("usuarioLogado")
    public String usuarioLogado(@AuthenticationPrincipal OAuth2User principal) {
        if (principal == null) {
            return null;
        }

        Object nome = principal.getAttribute("name");
        if (nome != null) return nome.toString();

        Object preferredUsername = principal.getAttribute("preferred_username");
        if (preferredUsername != null) return preferredUsername.toString();

        Object givenName = principal.getAttribute("given_name");
        if (givenName != null) return givenName.toString();

        return principal.getName();
    }

    @ModelAttribute("emailLogado")
    public String emailLogado(@AuthenticationPrincipal OAuth2User principal) {
        if (principal == null) {
            return null;
        }

        Object email = principal.getAttribute("email");
        return email != null ? email.toString() : null;
    }

    @ModelAttribute("perfilLogado")
    public String perfilLogado(@AuthenticationPrincipal OAuth2User principal) {
        if (principal == null) return null;

        Object resourceAccessObj = principal.getAttribute("resource_access");
        if (resourceAccessObj instanceof java.util.Map<?, ?> resourceAccess) {
            Object clientObj = resourceAccess.get("scc-app");
            if (clientObj instanceof java.util.Map<?, ?> clientMap) {
                Object rolesObj = clientMap.get("roles");
                if (rolesObj instanceof java.util.Collection<?> roles) {
                    for (Object role : roles) {
                        String r = role.toString();
                        if ("SCC_ADMIN".equals(r)) return "Administrador";
                        if ("SCC_GESTOR".equals(r)) return "Gestor";
                        if ("SCC_CLIENTE".equals(r)) return "Cliente";
                    }
                }
            }
        }

        return "Usuário";
    }
}