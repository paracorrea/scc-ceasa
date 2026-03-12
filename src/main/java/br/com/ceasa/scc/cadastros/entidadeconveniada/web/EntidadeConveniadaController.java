package br.com.ceasa.scc.cadastros.entidadeconveniada.web;

import br.com.ceasa.scc.cadastros.entidadeconveniada.domain.EntidadeConveniada;
import br.com.ceasa.scc.cadastros.entidadeconveniada.service.EntidadeConveniadaService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@Controller
@RequestMapping("/cadastros/entidades-conveniadas")
@RequiredArgsConstructor
public class EntidadeConveniadaController {

    private final EntidadeConveniadaService service;

    @GetMapping
    public String listar(Model model) {
        model.addAttribute("entidades", service.listar());
        return "cadastros/entidadeconveniada/list";
    }

    @GetMapping("/novo")
    public String novo(Model model) {
        model.addAttribute("entidade", EntidadeConveniada.builder().build());
        return "cadastros/entidadeconveniada/form";
    }

    @PostMapping
    public String salvar(@ModelAttribute("entidade") EntidadeConveniada entidade) {
        service.salvar(entidade);
        return "redirect:/cadastros/entidades-conveniadas";
    }

    @GetMapping("/{id}/editar")
    public String editar(@PathVariable UUID id, Model model) {
        model.addAttribute("entidade", service.buscar(id));
        return "cadastros/entidadeconveniada/form";
    }
}