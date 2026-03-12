package br.com.ceasa.scc.cadastros.entidadeconveniada.web;

import br.com.ceasa.scc.cadastros.entidadeconveniada.domain.ContaBancariaEntidade;
import br.com.ceasa.scc.cadastros.entidadeconveniada.service.ContaBancariaEntidadeService;
import br.com.ceasa.scc.cadastros.entidadeconveniada.service.EntidadeConveniadaService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@Controller
@RequestMapping("/cadastros/entidades-conveniadas/{entidadeId}/contas-bancarias")
@RequiredArgsConstructor
public class ContaBancariaEntidadeController {

    private final ContaBancariaEntidadeService service;
    private final EntidadeConveniadaService entidadeService;

    @GetMapping
    public String listar(@PathVariable UUID entidadeId, Model model) {
        model.addAttribute("entidade", entidadeService.buscar(entidadeId));
        model.addAttribute("contas", service.listarPorEntidade(entidadeId));
        return "cadastros/entidadeconveniada/conta-list";
    }

    @GetMapping("/novo")
    public String novo(@PathVariable UUID entidadeId, Model model) {
        model.addAttribute("entidade", entidadeService.buscar(entidadeId));
        model.addAttribute("conta", ContaBancariaEntidade.builder().build());
        return "cadastros/entidadeconveniada/conta-form";
    }

    @PostMapping
    public String salvar(@PathVariable UUID entidadeId,
                         @ModelAttribute("conta") ContaBancariaEntidade conta) {
        service.salvar(entidadeId, conta);
        return "redirect:/cadastros/entidades-conveniadas/" + entidadeId + "/contas-bancarias";
    }

    @GetMapping("/{id}/editar")
    public String editar(@PathVariable UUID entidadeId, @PathVariable UUID id, Model model) {
        model.addAttribute("entidade", entidadeService.buscar(entidadeId));
        model.addAttribute("conta", service.buscar(id));
        return "cadastros/entidadeconveniada/conta-form";
    }
}