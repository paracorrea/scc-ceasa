package br.com.ceasa.scc.planejamento.planotrabalho.web;

import br.com.ceasa.scc.cadastros.entidadeconveniada.service.EntidadeConveniadaService;
import br.com.ceasa.scc.planejamento.planotrabalho.domain.PlanoTrabalho;
import br.com.ceasa.scc.planejamento.planotrabalho.service.PlanoTrabalhoService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@Controller
@RequestMapping("/planejamento/planos-trabalho")
@RequiredArgsConstructor
public class PlanoTrabalhoController {

    private final PlanoTrabalhoService service;
    private final EntidadeConveniadaService entidadeService;

    @GetMapping
    public String listar(Model model) {
        model.addAttribute("planos", service.listar());
        return "planejamento/planotrabalho/list";
    }

    @GetMapping("/novo")
    public String novo(Model model) {
        model.addAttribute("plano", PlanoTrabalho.builder().build());
        model.addAttribute("entidades", entidadeService.listar());
        return "planejamento/planotrabalho/form";
    }

    @PostMapping
    public String salvar(@ModelAttribute("plano") PlanoTrabalho plano) {
        PlanoTrabalho salvo = service.salvar(plano);
        return "redirect:/planejamento/planos-trabalho/" + salvo.getId() + "/editar";
    }

    @GetMapping("/{id}/editar")
    public String editar(@PathVariable UUID id, Model model) {
        model.addAttribute("plano", service.buscar(id));
        model.addAttribute("entidades", entidadeService.listar());
        return "planejamento/planotrabalho/form";
    }
}