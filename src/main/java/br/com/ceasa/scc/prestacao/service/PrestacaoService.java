package br.com.ceasa.scc.prestacao.service;

import br.com.ceasa.scc.common.exception.BusinessException;
import br.com.ceasa.scc.common.exception.NotFoundException;
import br.com.ceasa.scc.convenios.convenio.domain.Convenio;
import br.com.ceasa.scc.convenios.convenio.service.ConvenioService;
import br.com.ceasa.scc.prestacao.domain.Prestacao;
import br.com.ceasa.scc.prestacao.repository.PrestacaoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PrestacaoService {

    private final PrestacaoRepository repository;
    private final ConvenioService convenioService;

    public List<Prestacao> listar() {
        return repository.findAllByOrderByMesReferenciaDesc();
    }

    public Prestacao buscar(UUID id) {
        return repository.findById(id)
                .orElseThrow(() -> new NotFoundException("Prestação não encontrada."));
    }

    public Prestacao criar(UUID convenioId, LocalDate mesReferencia) {
        LocalDate referencia = mesReferencia.withDayOfMonth(1);

        repository.findByConvenioIdAndMesReferencia(convenioId, referencia)
                .ifPresent(p -> {
                    throw new BusinessException("Já existe prestação para este convênio neste mês.");
                });

        Convenio convenio = convenioService.buscar(convenioId);

        Prestacao prestacao = Prestacao.builder()
                .convenio(convenio)
                .mesReferencia(referencia)
                .status("PENDENTE")
                .build();

        return repository.save(prestacao);
    }
}