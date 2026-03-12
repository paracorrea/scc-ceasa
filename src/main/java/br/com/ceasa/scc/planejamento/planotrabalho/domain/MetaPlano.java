package br.com.ceasa.scc.planejamento.planotrabalho.domain;

import jakarta.persistence.*;
import lombok.*;

import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "scc_meta_plano")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MetaPlano {

    @Id
    @GeneratedValue
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "plano_trabalho_id", nullable = false)
    private PlanoTrabalho planoTrabalho;

    @Column(nullable = false, length = 1000)
    private String descricao;

    @OneToMany(mappedBy = "metaPlano", cascade = CascadeType.ALL, orphanRemoval = false)
    @Builder.Default
    private List<EtapaPlano> etapas = new ArrayList<>();

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