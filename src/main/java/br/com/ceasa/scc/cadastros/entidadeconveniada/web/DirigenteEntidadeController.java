package br.com.ceasa.scc.cadastros.entidadeconveniada.web;

import br.com.ceasa.scc.cadastros.entidadeconveniada.domain.DirigenteEntidade;
import br.com.ceasa.scc.cadastros.entidadeconveniada.service.DirigenteEntidadeService;
import br.com.ceasa.scc.cadastros.entidadeconveniada.service.EntidadeConveniadaService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@Controller
@RequestMapping("/cadastros/entidades-conveniadas/{entidadeId}/dirigentes")
@RequiredArgsConstructor
public class DirigenteEntidadeController {

    private final DirigenteEntidadeService service;
    private final EntidadeConveniadaService entidadeService;

    @GetMapping
    public String listar(@PathVariable UUID entidadeId, Model model) {
        model.addAttribute("entidade", entidadeService.buscar(entidadeId));
        model.addAttribute("dirigentes", service.listarPorEntidade(entidadeId));
        return "cadastros/entidadeconveniada/dirigente-list";
    }

    @GetMapping("/novo")
    public String novo(@PathVariable UUID entidadeId, Model model) {
        model.addAttribute("entidade", entidadeService.buscar(entidadeId));
        model.addAttribute("dirigente", DirigenteEntidade.builder().build());
        return "cadastros/entidadeconveniada/dirigente-form";
    }

    @PostMapping
    public String salvar(@PathVariable UUID entidadeId,
                         @ModelAttribute("dirigente") DirigenteEntidade dirigente) {
        service.salvar(entidadeId, dirigente);
        return "redirect:/cadastros/entidades-conveniadas/" + entidadeId + "/dirigentes";
    }

    @GetMapping("/{id}/editar")
    public String editar(@PathVariable UUID entidadeId, @PathVariable UUID id, Model model) {
        model.addAttribute("entidade", entidadeService.buscar(entidadeId));
        model.addAttribute("dirigente", service.buscar(id));
        return "cadastros/entidadeconveniada/dirigente-form";
    }
}