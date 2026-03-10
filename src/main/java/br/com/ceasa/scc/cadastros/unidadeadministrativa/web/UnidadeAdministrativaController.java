package br.com.ceasa.scc.cadastros.unidadeadministrativa.web;

import br.com.ceasa.scc.cadastros.unidadeadministrativa.domain.UnidadeAdministrativa;
import br.com.ceasa.scc.cadastros.unidadeadministrativa.service.UnidadeAdministrativaService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@Controller
@RequestMapping("/cadastros/unidades")
@RequiredArgsConstructor
public class UnidadeAdministrativaController {

    private final UnidadeAdministrativaService service;

    @GetMapping
    public String listar(Model model) {
        model.addAttribute("unidades", service.listarAtivas());
        return "cadastros/unidade/list";
    }

    @GetMapping("/novo")
    public String novo(Model model) {
        model.addAttribute("unidade", UnidadeAdministrativa.builder().ativo(true).build());
        return "cadastros/unidade/form";
    }

    @PostMapping
    public String salvar(@ModelAttribute("unidade") UnidadeAdministrativa unidade) {
        service.salvar(unidade);
        return "redirect:/cadastros/unidades";
    }

    @GetMapping("/{id}/editar")
    public String editar(@PathVariable UUID id, Model model) {
        model.addAttribute("unidade", service.buscar(id));
        return "cadastros/unidade/form";
    }

    @PostMapping("/{id}/inativar")
    public String inativar(@PathVariable UUID id) {
        service.inativar(id);
        return "redirect:/cadastros/unidades";
    }
}
