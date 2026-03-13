package br.com.ceasa.scc.convenios.convenio.web;

import br.com.ceasa.scc.cadastros.unidadeadministrativa.service.UnidadeAdministrativaService;
import br.com.ceasa.scc.convenios.convenio.domain.Convenio;
import br.com.ceasa.scc.convenios.convenio.service.ConvenioService;
import br.com.ceasa.scc.planejamento.planotrabalho.service.PlanoTrabalhoService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@Controller
@RequestMapping("/convenios")
@RequiredArgsConstructor
public class ConvenioController {

    private final ConvenioService service;
    private final PlanoTrabalhoService planoTrabalhoService;
    private final UnidadeAdministrativaService unidadeAdministrativaService;

    @GetMapping
    public String listar(Model model) {
        model.addAttribute("convenios", service.listar());
        return "convenios/convenio/list";
    }

    @GetMapping("/novo")
    public String novo(Model model) {
        model.addAttribute("convenio", Convenio.builder().build());
        carregarCombos(model);
        return "convenios/convenio/form";
    }

    @PostMapping
    public String salvar(@ModelAttribute("convenio") Convenio convenio) {
        Convenio salvo = service.salvar(convenio);
        return "redirect:/convenios/" + salvo.getId() + "/editar";
    }

    @GetMapping("/{id}/editar")
    public String editar(@PathVariable UUID id, Model model) {
        model.addAttribute("convenio", service.buscar(id));
        carregarCombos(model);
        return "convenios/convenio/form";
    }

    private void carregarCombos(Model model) {
        model.addAttribute("planos", planoTrabalhoService.listar());
        model.addAttribute("unidades", unidadeAdministrativaService.listarAtivas());
    }
}