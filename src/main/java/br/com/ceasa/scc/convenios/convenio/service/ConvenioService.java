package br.com.ceasa.scc.convenios.convenio.service;

import br.com.ceasa.scc.cadastros.unidadeadministrativa.domain.UnidadeAdministrativa;
import br.com.ceasa.scc.cadastros.unidadeadministrativa.service.UnidadeAdministrativaService;
import br.com.ceasa.scc.common.exception.BusinessException;
import br.com.ceasa.scc.common.exception.NotFoundException;
import br.com.ceasa.scc.convenios.convenio.domain.Convenio;
import br.com.ceasa.scc.convenios.convenio.repository.ConvenioRepository;
import br.com.ceasa.scc.planejamento.planotrabalho.domain.PlanoTrabalho;
import br.com.ceasa.scc.planejamento.planotrabalho.service.PlanoTrabalhoService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ConvenioService {

    private final ConvenioRepository repository;
    private final PlanoTrabalhoService planoTrabalhoService;
    private final UnidadeAdministrativaService unidadeAdministrativaService;

    @Transactional(readOnly = true)
    public List<Convenio> listar() {
        return repository.findAllByOrderByDataInicioDesc();
    }

    @Transactional(readOnly = true)
    public Convenio buscar(UUID id) {
        return repository.findById(id)
                .orElseThrow(() -> new NotFoundException("Convênio não encontrado."));
    }

    @Transactional
    public Convenio salvar(Convenio convenio) {
        validarNumeroUnico(convenio);

        PlanoTrabalho plano = planoTrabalhoService.buscar(convenio.getPlanoTrabalho().getId());

        UnidadeAdministrativa unidade = null;
        if (convenio.getUnidadeAdministrativa() != null
                && convenio.getUnidadeAdministrativa().getId() != null) {
            unidade = unidadeAdministrativaService.buscar(convenio.getUnidadeAdministrativa().getId());
        }

        if (convenio.getId() == null) {
            convenio.setPlanoTrabalho(plano);
            convenio.setUnidadeAdministrativa(unidade);

            if (convenio.getStatus() == null || convenio.getStatus().isBlank()) {
                convenio.setStatus("ATIVO");
            }
            if (convenio.getValorTotal() == null) {
                convenio.setValorTotal(BigDecimal.ZERO);
            }

            return repository.save(convenio);
        }

        Convenio existente = buscar(convenio.getId());
        existente.setPlanoTrabalho(plano);
        existente.setUnidadeAdministrativa(unidade);
        existente.setNumero(convenio.getNumero());
        existente.setProtocolo(convenio.getProtocolo());
        existente.setObjeto(convenio.getObjeto());
        existente.setDataAssinatura(convenio.getDataAssinatura());
        existente.setDataInicio(convenio.getDataInicio());
        existente.setDataFim(convenio.getDataFim());
        existente.setValorTotal(convenio.getValorTotal() != null ? convenio.getValorTotal() : BigDecimal.ZERO);
        existente.setStatus((convenio.getStatus() != null && !convenio.getStatus().isBlank()) ? convenio.getStatus() : "ATIVO");

        return repository.save(existente);
    }

    private void validarNumeroUnico(Convenio convenio) {
        repository.findByNumero(convenio.getNumero())
                .ifPresent(existente -> {
                    if (convenio.getId() == null || !existente.getId().equals(convenio.getId())) {
                        throw new BusinessException("Já existe um convênio com este número.");
                    }
                });
    }
}