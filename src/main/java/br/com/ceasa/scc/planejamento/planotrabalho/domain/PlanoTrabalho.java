package br.com.ceasa.scc.planejamento.planotrabalho.domain;

import br.com.ceasa.scc.cadastros.entidadeconveniada.domain.EntidadeConveniada;
import jakarta.persistence.*;
import lombok.*;

import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "scc_plano_trabalho")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PlanoTrabalho {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "entidade_conveniada_id", nullable = false)
    private EntidadeConveniada entidadeConveniada;

    @Column(nullable = false)
    private Integer edicao;

    @Column(nullable = false, length = 40)
    private String status;

    @Column(nullable = false, length = 1000)
    private String descricao;

    @OneToMany(mappedBy = "planoTrabalho", cascade = CascadeType.ALL, orphanRemoval = false)
    @Builder.Default
    private List<MetaPlano> metas = new ArrayList<>();

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    @PrePersist
    void prePersist() {
        OffsetDateTime now = OffsetDateTime.now();
        if (createdAt == null) createdAt = now;
        if (updatedAt == null) updatedAt = now;
    }

    @PreUpdate
    void preUpdate() {
        updatedAt = OffsetDateTime.now();
    }
}