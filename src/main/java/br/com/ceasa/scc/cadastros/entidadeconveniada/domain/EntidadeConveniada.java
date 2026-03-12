package br.com.ceasa.scc.cadastros.entidadeconveniada.domain;

import jakarta.persistence.*;
import lombok.*;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "scc_entidade_conveniada")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EntidadeConveniada {

    @Id
    @GeneratedValue
    private UUID id;

    @Column(nullable = false, length = 255)
    private String nome;

    @Column(nullable = false, length = 18, unique = true)
    private String cnpj;

    @Column(length = 255)
    private String email;

    @Column(length = 50)
    private String telefone;

    @Column(length = 120)
    private String cidade;

    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    @OneToMany(mappedBy = "entidadeConveniada")
    private List<DirigenteEntidade> dirigentes;

    @OneToMany(mappedBy = "entidadeConveniada")
    private List<ContaBancariaEntidade> contasBancarias;
    
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