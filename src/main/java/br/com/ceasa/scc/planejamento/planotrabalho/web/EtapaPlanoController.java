package br.com.ceasa.scc.planejamento.planotrabalho.web;

import br.com.ceasa.scc.cadastros.despesa.repository.DespesaRepository;
import br.com.ceasa.scc.cadastros.despesa.repository.ItemDespesaRepository;
import br.com.ceasa.scc.planejamento.planotrabalho.domain.EtapaPlano;
import br.com.ceasa.scc.planejamento.planotrabalho.service.EtapaPlanoService;
import br.com.ceasa.scc.planejamento.planotrabalho.service.MetaPlanoService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@Controller
@RequestMapping("/planejamento/metas/{metaId}/etapas")
@RequiredArgsConstructor
public class EtapaPlanoController {

    private final EtapaPlanoService service;
    private final MetaPlanoService metaService;
    private final DespesaRepository despesaRepository;
    private final ItemDespesaRepository itemDespesaRepository;

    @GetMapping
    public String listar(@PathVariable UUID metaId, Model model) {
        model.addAttribute("meta", metaService.buscar(metaId));
        model.addAttribute("etapas", service.listarPorMeta(metaId));
        return "planejamento/planotrabalho/etapa-list";
    }

    @GetMapping("/novo")
    public String novo(@PathVariable UUID metaId, Model model) {
        model.addAttribute("meta", metaService.buscar(metaId));
        model.addAttribute("etapa", EtapaPlano.builder().build());
        model.addAttribute("despesas", despesaRepository.findAllByOrderByOrdemAscNomeAsc());
        model.addAttribute("itensDespesa", itemDespesaRepository.findAll());
        return "planejamento/planotrabalho/etapa-form";
    }

    @PostMapping
    public String salvar(@PathVariable UUID metaId,
                         @ModelAttribute("etapa") EtapaPlano etapa) {
        service.salvar(metaId, etapa);
        return "redirect:/planejamento/metas/" + metaId + "/etapas";
    }

    @GetMapping("/{id}/editar")
    public String editar(@PathVariable UUID metaId, @PathVariable UUID id, Model model) {
        model.addAttribute("meta", metaService.buscar(metaId));
        model.addAttribute("etapa", service.buscar(id));
        model.addAttribute("despesas", despesaRepository.findAllByOrderByOrdemAscNomeAsc());
        model.addAttribute("itensDespesa", itemDespesaRepository.findAll());
        return "planejamento/planotrabalho/etapa-form";
    }
}