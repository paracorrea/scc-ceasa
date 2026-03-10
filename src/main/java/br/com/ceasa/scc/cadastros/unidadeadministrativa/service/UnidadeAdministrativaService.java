package br.com.ceasa.scc.cadastros.unidadeadministrativa.service;

import br.com.ceasa.scc.cadastros.unidadeadministrativa.domain.UnidadeAdministrativa;
import br.com.ceasa.scc.cadastros.unidadeadministrativa.repository.UnidadeAdministrativaRepository;
import br.com.ceasa.scc.common.exception.NotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UnidadeAdministrativaService {

    private final UnidadeAdministrativaRepository repository;

    @Transactional(readOnly = true)
    public List<UnidadeAdministrativa> listarAtivas() {
        return repository.findByAtivoTrueOrderByNomeAsc();
    }

    @Transactional(readOnly = true)
    public UnidadeAdministrativa buscar(UUID id) {
        return repository.findById(id)
                .orElseThrow(() -> new NotFoundException("Unidade Administrativa não encontrada."));
    }

    @Transactional
    public UnidadeAdministrativa salvar(UnidadeAdministrativa unidade) {
        if (unidade.getId() == null) {
            return repository.save(unidade);
        }

        UnidadeAdministrativa existente = buscar(unidade.getId());
        existente.setNome(unidade.getNome());
        existente.setSigla(unidade.getSigla());
        existente.setAtivo(unidade.isAtivo());

        return repository.save(existente);
    }
    @Transactional
    public void inativar(UUID id) {
        UnidadeAdministrativa u = buscar(id);
        u.setAtivo(false);
        repository.save(u);
    }
}
