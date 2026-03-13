package br.com.ceasa.scc.prestacao.web;

import br.com.ceasa.scc.convenios.convenio.service.ConvenioService;
import br.com.ceasa.scc.prestacao.service.PrestacaoService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.UUID;

@Controller
@RequestMapping("/prestacoes")
@RequiredArgsConstructor
public class PrestacaoController {

    private final PrestacaoService service;
    private final ConvenioService convenioService;

    @GetMapping
    public String listar(Model model) {
        model.addAttribute("prestacoes", service.listar());
        return "prestacoes/list";
    }

    @GetMapping("/nova")
    public String nova(Model model) {
        model.addAttribute("convenios", convenioService.listar());
        return "prestacoes/form";
    }

    @PostMapping
    public String criar(
            @RequestParam UUID convenioId,
            @RequestParam String mesReferencia
    ) {
        LocalDate referencia = YearMonth.parse(mesReferencia).atDay(1);

        var prestacao = service.criar(convenioId, referencia);

        return "redirect:/prestacoes/" + prestacao.getId();
    }
}