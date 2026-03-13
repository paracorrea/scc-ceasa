package br.com.ceasa.scc.planejamento.planotrabalho.web;

import br.com.ceasa.scc.planejamento.planotrabalho.domain.MetaPlano;
import br.com.ceasa.scc.planejamento.planotrabalho.service.MetaPlanoService;
import br.com.ceasa.scc.planejamento.planotrabalho.service.PlanoTrabalhoService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@Controller
@RequestMapping("/planejamento/planos-trabalho/{planoId}/metas")
@RequiredArgsConstructor
public class MetaPlanoController {

    private final MetaPlanoService service;
    private final PlanoTrabalhoService planoService;

    @GetMapping
    public String listar(@PathVariable UUID planoId, Model model) {
        model.addAttribute("plano", planoService.buscar(planoId));
        model.addAttribute("metas", service.listarPorPlano(planoId));
        return "planejamento/planotrabalho/meta-list";
    }

    @GetMapping("/novo")
    public String novo(@PathVariable UUID planoId, Model model) {
        model.addAttribute("plano", planoService.buscar(planoId));
        model.addAttribute("meta", MetaPlano.builder().build());
        return "planejamento/planotrabalho/meta-form";
    }

    @PostMapping
    public String salvar(@PathVariable UUID planoId,
                         @ModelAttribute("meta") MetaPlano meta) {
        service.salvar(planoId, meta);
        return "redirect:/planejamento/planos-trabalho/" + planoId + "/metas";
    }

    @GetMapping("/{id}/editar")
    public String editar(@PathVariable UUID planoId, @PathVariable UUID id, Model model) {
        model.addAttribute("plano", planoService.buscar(planoId));
        model.addAttribute("meta", service.buscar(id));
        return "planejamento/planotrabalho/meta-form";
    }
}